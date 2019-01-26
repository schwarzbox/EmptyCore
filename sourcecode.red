; invisible constants
do [
    coredir: %core/
    navdir: to-red-file rejoin [what-dir copy coredir]
    hiddenfiles: true
    delay: 0.15
    make-dir coredir
    change-dir coredir
    deffile: to-red-file rejoin [what-dir "newcode"]
    codefile: copy deffile

    autosave: func [codesource][
        either (exists? codefile) and (codefile <> deffile)[
            write codefile codesource
        ][
            file: request-file/file/save deffile
            if file [
                file: copy to-red-file file
                ; WIP leftshift
                ; print [codefile file]
                ; probe openfiles
                replace openfiles codefile file
                ; probe openfiles
                codefile: copy file
                write codefile codesource
            ]
        ]
    ]
    openfiles: copy []
    codefnt: make font! [name: "Andale Mono" style: [regular]
                                        size: 10 color: gray]

    updtab: func [face][
        clear codemill/text
        if exists? codefile [codemill/text: read codefile]

        spl: split-path codefile
        nametab: copy form spl/2
        foreach tab tabpan/pane [
            either nametab = tab/pane/1/text [
            face/color: dispclr
            ][
                tab/color: mainclr
            ]
        ]
    ]

    removetab: func [tab file] [
        ind: index? find openfiles file
        remove find tabpan/pane tab
        remove find openfiles file
        newfile: pick openfiles (ind - 1)
        if (not newfile) [ newfile: first openfiles]
        if newfile [codefile: copy to-red-file newfile]
        changetabs
    ]

    changetabs: does [
        comtab: copy "origin 0x0 space 0x0 "
        foreach fl openfiles [
            spl: split-path fl
            nametab: copy form spl/2
            basename: rejoin ["_" nametab]
            replace basename "." ""
            append comtab rejoin [basename ": " {panel dispclr [origin 0x0 space 0x0 text "} nametab {" center font codefnt text "×" 16 font codefnt on-up [removetab }basename{ %}fl{]] on-down [ autosave codemill/text codefile: copy %}fl{ updtab face] on-create [updtab face]}]
        ]
        do [tabpan/pane: layout/only load form comtab]
        if (length? openfiles) = 0 [clear codemill/text]
        clear comtab
    ]

    opentab: func [file][
        append openfiles file
        codefile: copy file
        changetabs
    ]

    closepanel: function [txt low high] [
        either txt = "▾" [
            txt: "▸"
            return compose [(txt) (low)]
        ][
            txt: "▾"
            return compose [(txt) (high)]
        ]
    ]

    navigation: does [
        dirlist: copy split (form read navdir) " "
        if not hiddenfiles [
            remove-each file dirlist [(first file) = #"." ]
        ]
        insert dirlist ".."
        iolist/data: sort dirlist
    ]
]

sourcecode: [
    ; constants
    origin 0x0 space 1x0
    style display: area dispclr wrap font codefnt no-border
    style numbar: area dispclr font codefnt font-color gray no-border
    below

    codepan: panel mainclr [
        below
        origin 0x0 space 1x0
        panel [
            origin 0x0 space 0x0
            codeclose: text "▾" 16 center font syswinfnt on-down [
                either face/text = "▾" [
                    face/text: "▸"
                    codemill/size: 598x0
                    codenumbers/size: 41x0
                ][
                    face/text: "▾"
                    codemill/size: 598x370
                    codenumbers/size: 41x370
                ]
            ]
            do [getinput: false]
            codelabel: text "CodeMill" 72 font syswinfnt
            tabpan: panel 542x19 mainclr [ ]
        ]
        across

        codenumbers: numbar "1" right 41x370 on-focus [set-focus codemill]
        do [
            scroller: get-scroller codenumbers 'vertical
            scroller/visible?: false
        ]
        codemill: display "" focus 598x370 font-size 10 font-color codeclr on-change [
                if (length? openfiles) = 0 [
                    append openfiles copy deffile
                    changetabs
                ]
                getinput: false
                newline: "^(line)"

                numbers: do [split face/text newline]
                clear codenumbers/text
                i: 0
            foreach stroke numbers [
                i: i + 1
                append codenumbers/text rejoin [i newline]
            ]
            defcom: replace/all copy codemill/text "print" {append append terminal/text newline form reduce}
            defcom: replace/all defcom "prin" {append append terminal/text to string! reduce}
            defcom: replace/all defcom "print" {append append terminal/text newline form}
            defcom: replace/all defcom "input" {view [do[getinput: true set-focus terminal]]}
            defcom: replace/all defcom "ask" {view [do[getinput: true set-focus terminal]]}
            ; view output
            docom: string!
            viewcom: find defcom "view"

            if viewcom [
                bl: 0
                br: 0
                counter: 0
                rule: false
                until [
                    counter: counter + 1
                    ch: pick viewcom counter
                    if ch = #"[" [bl: bl + 1]
                    if ch = #"]" [br: br + 1]
                    rule: (((bl > 0) and (br = bl)) or (counter > length? viewcom))
                ]
                viewcom: copy/part viewcom counter tail viewcom
                print viewcom
                docom: copy viewcom
                docom: replace/all docom "view" ""
                do [attempt [viewengine/pane: layout/only load form docom]]
                defcom: replace/all copy defcom viewcom ""
            ]
            ; terminal output
            clear terminal/text
            terminal/text: rejoin ["Red " form system/version]
            ; avoid q programm
            if not defcom = "q" [attempt [do defcom]]
            ; add newline when getinput
            if getinput [terminal/text: rejoin [terminal/text newline]]

            ; WIP numbers
            textsize: size-text face
            ; overflow: face/size - textsize
            ; print overflow
            ; print textsize
            ; print [offset-to-caret face textsize]
            ; codenumbers/selected: 1x10
            ; print face/offset
            ; print codenumbers/offset/y: -19
        ]on-over[

        ]on-unfocus [if not getinput [set-focus face]
        ]on-key-down [
            if (⌘) [
                case [
                    event/key = #"N" [
                        if (length? openfiles) > 0 [
                            autosave face/text
                        ]
                        opentab copy deffile
                    ]
                    event/key = #"S" [
                        if (length? openfiles) = 0 [
                            append openfiles copy deffile
                        ]
                        autosave face/text
                        changetabs
                    ]
                    event/key = #"O" [
                        if (length? openfiles) > 0 [
                            autosave face/text
                        ]
                        file: request-file/file/filter coredir ["Red" "*.red"
                                                    "RedSystem" "*.reds"]
                        if file [
                            opentab to-red-file file
                        ]
                    ]
                ]
            ]
        ]
        return
        below
        terminalpan: panel mainclr [
            origin 0x0 space 0x0
            terminalclose: text "▾" 16 center font syswinfnt on-down [
                clos: closepanel face/text 640x0 640x104
                face/text: clos/1
                terminal/size: clos/2
            ]
            terminallabel: text "Terminal" font syswinfnt
        ]
        terminal: display "" 640x104 font-size 9 font-color codeclr on-key-down[
            ; enter 13
            if event/key = 13 [
                reversed: reverse copy terminal/text
                trash: find reversed "^^/"
                uservalue: reverse replace/all reversed trash ""
                codemill/text: replace/all codemill/text "input" uservalue
                codemill/text: replace/all codemill/text "ask" uservalue
                set-focus codemill
            ]
        ]
    ] loose
    return
    viewpan: panel mainclr [
        below
        origin 0x0 space 0x0
        panel [
            origin 0x0 space 0x0
            viewclose: text "▾" 16 center font syswinfnt on-down [
                clos: closepanel face/text 512x0 512x512
                face/text: clos/1
                viewengine/size: clos/2
            ]
            viewlabel: text "ViewEngine" font syswinfnt
        ]

        viewengine: panel 512x512 dispclr
    ] loose
    return
    drawpan: panel mainclr [
        below
        origin 0x0 space 0x0
        panel [
            origin 0x0 space 0x0
            drawclose: text "▾" 16 center font syswinfnt on-down [
                clos: closepanel face/text 256x0 256x256
                face/text: clos/1
                drawmachine/size: clos/2
            ]
            drawlabel: text "DrawMachine" font syswinfnt
        ]
        drawmachine: panel 256x256 dispclr
    ] loose

    iopan: panel mainclr [
        below
        origin 0x0 space 0x0
        panel [
            origin 0x0 space 0x0
            ioclose: text "▾" 16 center font syswinfnt on-down [
                clos: closepanel face/text 256x0 256x256
                face/text: clos/1
                iospace/size: clos/2
            ]
            iolabel: text "FileTree" font syswinfnt
            iohidden: text ".*" 32 font syswinfnt on-down [
                either hiddenfiles [
                    hiddenfiles: false
                    face/font/color: gray
                ][
                    hiddenfiles: true
                    face/font/color: sysclr
                ]
            ]
        ]
        iospace: panel 256x256 dispclr [
            origin 0x0 space 0x0
            iolist: text-list 256x256 data [] [
                sel: pick face/data face/selected
                if sel [
                    case [
                        sel = ".." [
                            if (last navdir) = #"/" [take/last navdir]
                            np: copy/part navdir index? (find/last navdir "/")
                            change-dir np
                            navdir: to-red-file get-current-dir
                            navigation
                            wait delay
                            face/selected: none
                        ]
                        (last sel) = #"/" [
                            change-dir rejoin [navdir sel]
                            navdir: to-red-file get-current-dir
                            navigation
                            wait delay
                            face/selected: none
                        ]
                        (suffix? sel) = ".red" [
                            file: copy to-red-file rejoin [navdir sel]
                            opentab file
                        ]
                        (suffix? sel) = ".reds" [
                            file: copy to-red-file rejoin [navdir sel]
                            opentab file
                        ]
                    ]
                ]
            ]
        ] on-create [navigation]
    ] loose
]

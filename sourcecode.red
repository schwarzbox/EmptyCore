; invisible constants
do [
    coredir: %core/
    hiddenfiles: true
    delay: 0.15
    stopexe: false
    make-dir coredir
    change-dir coredir
    homedir: to-red-file what-dir
    navdir: to-red-file what-dir
    deffile: "newcode.red"
    defdir: "newcore"
    extensions: [".red" ".reds" ".rtf" ".txt"]
    codefile: none

    codefnt: make font! [name: "Andale Mono" style: [regular]
                                        size: 10 color: gray]

    navigation: does [
        dirlist: copy split (form read navdir) " "
        if not hiddenfiles [
            remove-each file dirlist [(first file) = #"." ]
        ]
        if (first dirlist) = "" [take dirlist]
        insert dirlist ".."
        iolist/data: sort dirlist

        spl: split-path navdir
        print spl
        either spl/2 [ionavlab/text: form spl/2][ionavlab/text: form spl/1]
    ]

    autosave: does [write codefile codemill/text]

    openfile: func [file][
        if codefile [autosave]
        spl: split-path file
        namelab: copy form spl/2
        openfilelab/text: namelab
        codefile: copy file
        codemill/text: read codefile
    ]

    ifexist: func [file] [
        either find next file "." [
            name: copy/part file (index? find file ".") - 1
            ext: find file "."
        ][
            name: file
            ext: ""
        ]
        num: ""
        i: 1
        foreach fl read navdir [
            if find fl "/" [take/last fl]
            if fl = file [num: form i i: i + 1]
            file: to-red-file rejoin [name num ext]
        ]
        file: to-red-file rejoin [what-dir file]
        return file
    ]

    getdir: func [name] [
        if name [
            directory: ifexist name
            make-dir directory
        ]
    ]

    getfile: func [name] [
        if name [
            file: copy either find name "." [name][rejoin [name ".red"]]
            file: ifexist file
            write file "Red []^(line)"
            file
        ]
    ]

    tocreate: function [tit txt name][
        result: none
        View/options/flags [
            origin 4x4 space 0x1
            text txt 128 center font syswinfnt return
            return
            inp: field data name 128 dispclr focus no-border font syswinfnt on-enter[result: inp/text unview ]
        ][actors: object [
                on-create: func [face][
                    face/text: tit
                    place: iopan/offset + 132x96
                    face/offset: place
                    face/color: dispclr
                ]
            ]
        ]
        [no-min modal popup]
        result
    ]

    deletefile: func[file] [
        if codefile [
            spl: split-path codefile
            if file = spl/2 [
                clear codemill/text
                clear openfilelab/text
                codefile: none
            ]
        ]
        delete file
    ]

    toremove: function [file] [
        result: none
        View/options/flags [
            origin 4x4 space 0x1
            text "Remove?" 128 center font syswinfnt return
            text file 128 center font syswinfnt return
            yesbut: text "►" 128 center font syswinfnt on-down [
                face/font/color: gray
            ]on-up [face/font/color: sysclr result: true unview]
        ][actors: object [
                on-create: func [face][
                    face/text: "✖︎"
                    place: iopan/offset + 132x96
                    face/offset: place
                    face/color: dispclr
                ]
            ]
        ]
        [no-min modal popup]
        result
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

    execute: func [face] [
            if stopexe [exit]
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
        viewcom: find defcom "View"

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
            docom: replace/all docom "View" ""
            do [attempt [viewengine/pane: layout/only load form docom]]
            defcom: replace/all copy defcom viewcom ""
        ]
        ; terminal output
        clear terminal/text
        terminal/text: rejoin ["Red " form system/version]
        ; avoid q programm
        if not defcom = "Red []^/q" [attempt [do defcom]]
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
    ]
]

sourcecode: [
origin 0x0 space 1x0
    below
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
            iolabel: text "Tree" 48 font syswinfnt on-down [
                face/font/color: gray
            ]on-up [
                face/font/color: sysclr
                navdir: copy homedir
                navigation
            ]

            iocreatedir: text "❒" 24 center font syswinfnt on-down [
                face/font/color: gray
            ]on-up [
                face/font/color: sysclr
                getdir tocreate face/text "Create Dir" defdir
                navigation
            ]

            iocreatefile: text "✚" 24 center font syswinfnt on-down [
                face/font/color: gray
            ]on-up [
                face/font/color: sysclr
                getfile tocreate face/text "Create File" deffile
                navigation
            ]

            iorename: text "✎" 24 center font syswinfnt on-down[
                face/font/color: gray
            ]on-up [
                face/font/color: sysclr

                sel: iolist/selected
                if  (sel <> none)  [
                    name: tocreate face/text "Rename File" iolist/data/:sel
                    if (name <> none) [
                        oldfile: to-red-file iolist/data/:sel
                        tmpfile: read oldfile
                        deletefile oldfile
                        file: either find name "." [name][rejoin [name ".red"]]
                        file: ifexist file
                        write to-red-file file tmpfile
                        openfile file
                        navigation
                    ]
                ]
            ]

            ioremove: text "✖︎" 24 center font syswinfnt on-down[
                face/font/color: gray
            ]on-up [
                face/font/color: sysclr
                sel: iolist/selected
                if (sel <> none) [
                    isrem: toremove iolist/data/:sel
                    if isrem [
                        deletefile to-red-file iolist/data/:sel
                        navigation
                    ]
                ]
            ]

            iohidden: text ".*" 32 center font syswinfnt on-down [
                either hiddenfiles [
                    face/font/color: gray
                    hiddenfiles: false
                ][
                    face/font/color: sysclr
                    hiddenfiles: true
                ]
                navigation
            ]
        ]

        iospace: panel 256x256 dispclr [
            origin 0x0 space 0x0
            below

            ionavlab: text "" 256 font syswinfnt
            iofield: field 256x20 on-change[
                path: to-red-file face/text
                if dir? path [navdir: copy path navigation]
            ]
            iolist: text-list 256x236 data [] on-change [
                sel: pick face/data face/selected
                if sel [
                    if sel = ".." [
                        spl: split-path navdir
                        if spl [
                            change-dir spl/1
                            navdir: to-red-file get-current-dir
                            navigation
                            wait delay
                            face/selected: none
                        ]
                    ]
                ]
            ] on-dbl-click [
                sel: pick face/data face/selected
                if sel [
                    case [
                        (last sel) = #"/" [
                            change-dir rejoin [navdir sel]
                            navdir: to-red-file get-current-dir
                            navigation
                            wait delay
                            face/selected: none
                        ]
                        (find extensions form suffix? sel)[
                            file: copy to-red-file rejoin [navdir sel]
                            openfile file
                        ]
                    ]
                ]
            ]
        ] on-create [navigation]
    ] loose

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
    return

    style display: area dispclr wrap font codefnt no-border
    style numbar: area dispclr font codefnt font-color gray no-border

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
            codelabel: text "CodeMill" font syswinfnt
            openfilelab: text "" 256 font codefnt
        ]

        across
        codenumbers: numbar "" right 41x370 on-focus [set-focus codemill]
        do [
            scroller: get-scroller codenumbers 'vertical
            scroller/visible?: false
        ]
        codemill: display "" focus 598x370 font-size 10 font-color codeclr on-change [
                execute face
            ]on-over[

            ]on-key-down [
                if (⌘) [
                    case [
                        event/key = #"N" [
                            file: getfile deffile
                            openfile file
                            navigation
                        ]
                        event/key = #"S" [ autosave ]
                        event/key = #"B" [
                            stop: stopexe
                            if stop [stopexe: false]
                            execute codemill
                            stopexe: stop
                        ]
                    ]
                ]
                if (not codefile) [
                    file: getfile deffile
                    openfile file
                    navigation
                ]
            ]on-unfocus [
                if not getinput [set-focus face]
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
            terminalbut: text "✇" 16 font syswinfnt on-down[
                either stopexe [
                    stopexe: false face/font/color: sysclr
                    execute codemill
                ][
                    stopexe: true face/font/color: gray
                ]
            ]
        ]
        terminal: display "" 640x104 font-size 9 font-color codeclr on-key-down[
            ; enter 13
            if event/key = 13 [
                reversed: reverse copy terminal/text
                trash: find reversed "^/"
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

            viewrefresh: text "↺" 24 center font syswinfnt on-down [
                face/font/color: gray
            ]on-up [
                face/font/color: sysclr
                stop: stopexe
                if stop [stopexe: false]
                execute codemill
                stopexe: stop
            ]
        ]
        viewengine: panel 512x512 dispclr
    ] loose
    return
]

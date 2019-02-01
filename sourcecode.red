; invisible constants
do [
    coredir: %core/
    hiddenfiles: true
    stopexe: false
    newline: "^(line)"
    showerror: false
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

    closepanel: function [txt low high] [
        either txt = "▾" [
            txt: "▸"
            return compose [(txt) (low)]
        ][
            txt: "▾"
            return compose [(txt) (high)]
        ]
    ]

    treedef: func [place] [
        return rejoin [{
        }place{
        below
        treecli: field 256x20 on-change[
            path: to-red-file find/tail face/text ">"
            if (dir? path) [
                either error? try [read path][
                    navdir: rejoin [navdir path]
                ][
                    navdir: copy path
                ]
                navigation
            ]
        ]

        treelist: text-list 255x236 data [] on-change [
            sel: pick face/data face/selected
            if sel [
                if (find extensions form suffix? sel)[
                        file: copy to-red-file rejoin [navdir sel]
                        openfile file
                    ]
            ]
        ] on-dbl-click [
            sel: pick face/data face/selected
            if sel [
                case [
                    sel = ".." [
                        spl: split-path navdir
                        if spl [
                            change-dir spl/1
                            navdir: to-red-file get-current-dir
                            navigation
                        ]
                    ]
                    (last sel) = #"/" [
                        change-dir rejoin [navdir sel]
                        navdir: to-red-file get-current-dir
                        navigation
                    ]
                ]
            ]
        ]}]
    ]

    navigation: does [
        dirlist: copy split (form read navdir) " "
        if not hiddenfiles [
            remove-each file dirlist [(first file) = #"." ]
        ]
        if (first dirlist) = "" [take dirlist]
        insert dirlist ".."
        treelist/data: sort dirlist

        ; add for treeshell
        spl: split-path navdir
        either spl/2 [
            treecli/data: rejoin [spl/2 " >"]
        ][
            treecli/data: rejoin [spl/1 " >"]
        ]
    ]

    autosave: does [
        if codefile [write codefile codemill/text]]

    openfile: func [file][
        print codefile
        autosave
        spl: split-path file
        namelab: copy form spl/2
        openfilelab/text: namelab
        codefile: copy file
        codemill/text: read codefile

        ; error line?
        numbers: do [split codemill/text newline]
        clear codenumbers/text
        i: 0
        foreach stroke numbers [
            i: i + 1
            append codenumbers/text rejoin [i newline]
        ]
        set-focus codemill
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
        foreach fl sort read navdir [
            if find fl "/" [take/last fl]
            if fl = file [num: form i i: i + 1]
            file: rejoin [name num ext]
        ]
        file: to-red-file rejoin [what-dir file]
        return file
    ]

    setdir: func [name] [
        if name [
            directory: ifexist name
            make-dir directory
            navigation
        ]
    ]

    setfile: func [name] [
        if name [
            file: copy either find name "." [name][rejoin [name ".red"]]
            file: ifexist file
            write file "#!/usr/bin/env red^(line)Red []^(line)"
            openfile file
            navigation
        ]
    ]

    setname: func [name][
        if (name <> none) [
            oldfile: to-red-file treelist/data/:sel
            tmpfile: read oldfile
            rmrf oldfile
            file: either find name "." [name][rejoin [name ".red"]]
            file: ifexist file
            write to-red-file file tmpfile
            openfile file
            navigation
        ]
    ]

    askclose: func [] [
        clear treespace/pane
        treespace/pane: layout/only load form treedef "origin 0x0 space 0x0"
        navigation
        set-focus codemill
    ]

    askname: function [txt name /dr][
        clear treespace/pane
        treedialog: rejoin [{
            origin 0x0 space 0x2
            below
            text "}txt{" 256 center font syswinfnt
            do[clr: dispclr - 8]
            askinp: field 256 data "}name{" clr no-border font syswinfnt
                on-key-up [
                    if event/key = 13 [
                        either }dr{ [setdir askinp/text][setfile askinp/text]
                        askclose
                    ]
                ]
            across
            nobut: text "✕" 128 center font syswinfnt on-down [
                    face/font/color: gray
                ]on-up [
                    askclose
                ]
            yesbut: text "↳" 128 center font syswinfnt on-down [
                    face/font/color: gray
                ] on-up [face/font/color: sysclr
                    either }dr{ [setdir askinp/text][setfile askinp/text]
                    askclose
                ]
            } treedef "origin 0x64 space 0x0"
        ]
        treespace/pane: layout/only load form treedialog
        set-focus askinp
        navigation
    ]

    delfile: func [name][
        if name [
            rmrf to-red-file name
            navigation
        ]
    ]

    rmrf: func[file] [
        if codefile [
            spl: split-path codefile
            if file = spl/2 [
                clear codemill/text
                clear codenumbers/text
                clear console/text
                clear openfilelab/text
                codefile: none
            ]
        ]
        delete file
    ]

    ; askyes: function [tit txt name] [
    ;     result: none
    ;     View/options/flags [
    ;         origin 4x4 space 0x1
    ;         text txt 128 center font syswinfnt return
    ;         text name 128 center font syswinfnt return
    ;         yesbut: text "►" 128 center font syswinfnt on-down [
    ;             face/font/color: gray
    ;         ]on-up [face/font/color: sysclr result: name unview]
    ;     ][actors: object [
    ;             on-create: func [face][
    ;                 face/text: tit
    ;                 place: treepan/offset + 132x96
    ;                 face/offset: place
    ;                 face/color: dispclr
    ;             ]
    ;         ]
    ;     ]
    ;     [no-min modal popup]
    ;     result
    ; ]

    askyes: function [txt sel] [
        clear treespace/pane
        name: treelist/data/:sel
        treedialog: rejoin [{
            origin 0x0 space 0x2
            below
            do[clr: dispclr - 8]
            text "}txt{" 256 center font syswinfnt
            text "}name{" 256 center clr font syswinfnt
            across

            nobut: text "✕" 128 center font syswinfnt on-down [
                    face/font/color: gray
                ]on-up [
                    askclose
                ]
            yesbut: text "↳" 128 center font syswinfnt on-down [
                    face/font/color: gray
                ] on-up [face/font/color: sysclr
                    delfile "}name{"
                    askclose
                ]

            } treedef "origin 0x64 space 0x0"
        ]
        treespace/pane: layout/only load form treedialog
        navigation
    ]

    saferun: func [command][
        ; errors
        either showerror [
            if error? err: try command[
                append console/text rejoin["^/" err]
            ]
        ][attempt command]
    ]

    execute: func [face] [
        navdir: to-red-file what-dir
        getinput: false

        if stopexe [exit]

        ; console output
        clear console/text
        console/text: rejoin ["Red " form system/version]

        either find/match codemill/text "#!" [
            maincom: copy find/tail codemill/text newline

        ][
            maincom: copy codemill/text
        ]
        ; avoid to run Red []
        either find maincom "Red" [
            maincom: copy find/tail maincom "]"

        ][
            maincom: copy codemill/text
        ]

        maincom: replace/all maincom "print" {append append console/text newline form reduce}
        maincom: replace/all maincom "prin" {append append console/text to string! reduce}
        maincom: replace/all maincom "print" {append append console/text newline form}
        maincom: replace/all maincom "input" {view [do[getinput: true set-focus console]]}
        maincom: replace/all maincom "ask" {view [do[getinput: true set-focus console]]}

        ; view output
        tmpcom: string!
        viewcom: find maincom "View"

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
            ; print viewcom
            tmpcom: copy viewcom
            tmpcom: replace/all tmpcom "View" ""
            saferun [viewengine/pane: layout/only load form tmpcom]
            maincom: replace/all copy maincom viewcom ""
        ]
        ; avoid q programm
        if not maincom = "^/q" [
            saferun [do maincom]
        ]
        ; add newline when getinput
        if getinput [console/text: rejoin [console/text newline]]

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
    style display: area dispclr wrap font codefnt no-border
    style numbar: area dispclr font codefnt font-color gray no-border

    below
    treepan: panel mainclr [
        below
        origin 0x0 space 0x0
        panel [
            origin 0x0 space 0x0
            treeclose: text "▾" 16 center font syswinfnt on-down [
                clos: closepanel face/text 256x0 256x256
                face/text: clos/1
                treespace/size: clos/2
            ]
            treelabel: text "Tree" 48 center font syswinfnt on-down [
                face/font/color: gray
            ]
            on-up [
                face/font/color: sysclr
                navdir: copy homedir
                navigation
            ]

            treedir: text "❒" 24 center font syswinfnt on-down [face/font/color: gray
            ]on-up [
                face/font/color: sysclr
                setdir askname/dr "Create Dir" defdir
            ]

            treefile: text "✚" 24 center font syswinfnt  on-down[
                face/font/color: gray
            ]on-up [
                face/font/color: sysclr
                askname "Create File" deffile
            ]

            treename: text "✎" 24 center font syswinfnt on-down[
                face/font/color: gray
            ]on-up [
                face/font/color: sysclr
                sel: treelist/selected
                if  (sel <> none)  [
                    askname "Rename File" treelist/data/:sel
                ]
            ]

            treedel: text "✖︎" 24 center font syswinfnt on-down[
                face/font/color: gray
            ]on-up [
                face/font/color: sysclr
                sel: treelist/selected
                if (sel <> none) [
                    askyes "Remove File" sel
                ]
            ]

            treehide: text ".*" 32 center font syswinfnt on-down [
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

        treespace: panel 256x256 dispclr []
        do[treespace/pane: layout/only load form treedef "origin 0x0 space 0x0"]
        do[navigation]

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
        ; WIP
        do [
            scroller: get-scroller codenumbers 'vertical
            scroller/visible?: false
        ]
        codemill: display "" 598x370 focus font-size 10 font-color codeclr
             on-change [
                execute face
            ]on-over [
            ]on-key-down[
                if (not codefile) [setfile deffile]
            ]on-unfocus [
                if not getinput [set-focus face]
            ]on-create [codefile: none]
        return
        below
        consolepan: panel mainclr [
            origin 0x0 space 0x0
            consoleclose: text "▾" 16 center font syswinfnt on-down [
                clos: closepanel face/text 640x0 640x104
                face/text: clos/1
                console/size: clos/2
            ]
            consolelabel: text "Console" font syswinfnt
            consolereset: text "↺" 24 center font syswinfnt on-down [
                face/font/color: gray
            ]on-up [
                face/font/color: sysclr
                stop: stopexe
                if stop [stopexe: false]
                execute codemill
                stopexe: stop
            ]
            consolebut: text "∞" 24 font syswinfnt on-down[
                either stopexe [
                    stopexe: false
                    showerror: false
                    face/font/color: sysclr
                ][
                    stopexe: true
                    showerror: true
                    face/font/color: gray
                ]
            ]
        ]
        console: display "" 640x104 font-size 9 font-color codeclr on-key-down[
            ; enter 13
            if event/key = 13 [
                reversed: reverse copy console/text
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
        ]
        viewengine: panel 512x512 dispclr
    ] loose
    return
]

; sourcecode EmptyCore

; invisible constants
do [
    newline: "^(line)"
    askopen: none
    askfunc: does []

    extralight: 64
    hiddenfiles: true

    autorun: true
    showerror: false
    ; WIP
    userinput: []

    coredir: %core/
    make-dir coredir
    change-dir coredir
    homedir: to-red-file what-dir
    navdir: to-red-file what-dir
    deffile: "newcode.red"
    defdir: "newcore"
    extensions: [".red" ".reds" ".txt"]
    codefile: none
    codefnt: make font! [name: "Andale Mono"
                            style: [regular] size: 10 color: gray]
]

sourcecode: [
    origin 0x0 space 1x0
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
                ] on-over [flashbutton face event]
            treelabel: text "Tree" 48 center font syswinfnt on-up [
                    face/font/color: sysclr
                    navdir: copy homedir
                    navigation
                ] on-down [face/font/color: gray
                ] on-over [flashbutton face event]

            treedir: text "❒" 24 center font syswinfnt on-down [
                    closemenu face does [
                        askuser/folder face "Create Dir" defdir
                    ]
                ]

            treefile: text "✚" 24 center font syswinfnt on-down [
                    closemenu face does [
                        askuser/file face "Create File" deffile
                    ]
                ]

            treename: text "✎" 24 center font syswinfnt on-down [
                    sel: treelist/selected
                    if  (sel <> none) [
                        closemenu face does [
                            askuser/rename face "Rename" treelist/data/:sel
                        ]
                    ]
                ]

            treedel: text "✖︎" 24 center font syswinfnt on-up[
                    sel: treelist/selected
                    if (sel <> none) [
                        closemenu face does [
                            askuser/del face "Remove" treelist/data/:sel
                        ]
                    ]
                ]

            treehide: text ".*" 32 center font syswinfnt on-down [
                    either hiddenfiles [
                        hiddenfiles: false
                        face/font/color: gray
                    ][
                        hiddenfiles: true
                        face/font/color: sysclr
                    ]
                    navigation
                ]
        ]

        treeask: panel 256x0 mainclr [
            origin 0x0 space 0x4
            below
            asktext: text "" 256 center font syswinfnt
            askinp: area 256x16 "" center dispclr no-border font syswinfnt
                on-key-down[
                    if event/key = 13 [
                        askfunc
                        linenum: linenum + 1
                        showline
                    ]
                    if event/key = 27 [askclose]
                ]
                yesbut: text "↳" 256 center font syswinfnt on-up [
                        face/font/color: sysclr
                        askfunc
                    ] on-down [face/font/color: gray
                    ] on-over [flashbutton face event]
        ]

        treespace: panel 256x256 dispclr [
            origin 0x0 space 0x1
            below
            treecli: field 256x16 no-border on-change [
                unless find face/text ">" [append face/text ">"]
                treecom
            ] on-key-down[
                if (form event/key) = "left-command" [
                    path: find/tail face/text ">"
                    container: copy []
                    foreach file dirlist [
                        res: find/case/match file path
                        if res [append container res]
                    ]
                    if (length? container) = 1 [
                        append face/text container/1
                        treecom
                    ]
                ]
            ]

            treelist: text-list 256x240 data [] no-border on-change [
                sel: pick face/data face/selected
                if sel [
                    isfile sel
                    askinp/text: form sel
                ]
            ] on-dbl-click [
                sel: pick face/data face/selected
                if sel [
                    isback sel
                    isdir sel
                ]
            ]on-key-down [
                sel: pick face/data face/selected
                if (form event/key) = "right" [
                    if sel [
                        if (isfile sel) [execute codemill]
                        isdir sel
                    ]
                ]
                if (form event/key) = "left" [isback sel]
            ]
        ]on-create [navigation]
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
            ]on-over [flashbutton face event]
            drawlabel: text "DrawMachine" font syswinfnt
        ]
        drawmachine: panel 256x256 dispclr
    ] loose
    return

    style display: area dispclr wrap font codefnt no-border
    style numbar: area dispclr font codefnt font-size 10 font-color gray no-border

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
            ]on-over [flashbutton face event]

            do [getinput: false]
            codelabel: text "CodeMill" font syswinfnt
            codesavelab: text "" 24 font syswinfnt

            codefilelab: text "" 256 font codefnt
        ]

        across
        codenumbers: numbar "" right 41x370 disabled on-focus [
            set-focus codemill]

        codemill: display "" 598x370 focus font-size 10 font-color codeclr
             on-change [
                oldlines: codelines
                face/extra: copy codemill/text
                either ((form face/text) <> form (read codefile)) [
                    codesavelab/text: "○"
                ][
                    codesavelab/text: "●"
                ]
                navdir: to-red-file what-dir
                codelines: shownumbers

                if autorun [execute face]
            ]on-down [
                mousepos: event/offset
                codelines: shownumbers
                linenum: (mousepos/y / lineheight)
                if linenum >= (codelines) [
                    linenum: codelines - 1
                ]
                showline
            ]on-key-down[
                if (not codefile) [setfile deffile]
                if event/key = 'up [
                    if linenum > 0 [linenum: linenum - 1]
                    showline
                ]
                if event/key = 'down [
                    if linenum < 24 [linenum: linenum + 1]
                    showline
                ]
                if event/key = 13 [
                    linenum: linenum + 1
                    showline
                ]
            ]on-key-up[
                ; if event/key = 8 [
                    if (oldlines > codelines) [
                        oldlines: codelines
                        linenum: linenum - 1
                        showline
                    ]
                ; ]
            ]on-unfocus [
                if not getinput [set-focus face]
            ]on-over[
            ]on-create [
                codefile: none
                codelines: shownumbers
                oldlines:codelines
            ]
        return

        ; WIP
        at 0x19 flashline: base 41x15 with [color: sysclr + 0.0.0.222] on-focus [set-focus codemill]

        do [
            linenum: 0
            lineheight: codemill/size/y / 24
            showline: does[
                flashline/offset: 0x19 + (as-pair 0 (linenum * lineheight))
            ]
        ]

        below
        consolepan: panel mainclr [
            origin 0x0 space 0x0
            consoleclose: text "▾" 16 center font syswinfnt on-down [
                clos: closepanel face/text 640x0 640x104
                face/text: clos/1
                console/size: clos/2
            ]on-over [flashbutton face event]
            consolelabel: text "Console" font syswinfnt
            consolereset: text "↺" 24 center font syswinfnt on-up [
                face/font/color: sysclr
                build
            ]on-down [face/font/color: gray
            ]on-over [flashbutton face event]
            consolebut: text "∞" 24 font syswinfnt on-down[
                face/font/color: either autorun [
                    autorun: false
                    showerror: true
                    gray
                ][
                    autorun: true
                    showerror: false
                    sysclr
                ]
            ]
        ]
        console: display "" 640x104 font-size 9 font-color codeclr on-key-down[
            ; enter 13
            if event/key = 13 [
                userinput: copy []
                uservalue: copy find/last/tail console/text " "
                append userinput uservalue
                getinput: false
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
            ]on-over [flashbutton face event]
            viewlabel: text "ViewEngine" font syswinfnt
        ]
        viewengine: panel 512x512 dispclr
    ] loose
    return
]

; sourcecode EmptyCore

; invisible constants
do [
    newline: "^(line)"
    askopen: none
    askfunc: does []

    extralight: 96
    hiddenfiles: true

    autorun: true
    showerror: false
    ; WIP
    userinput: []

    drawinst: none
    drawline: false
    deletepixel: false
    fillpixel: false
    defimg: "newimg.png"
    imgext: [".png" ".jpeg"]

    coredir: %core/
    make-dir coredir
    change-dir coredir
    homedir: to-red-file what-dir
    navdir: to-red-file what-dir
    deffile: "newcode.red"
    defdir: "newcore"
    codext: [".red" ".reds" ".txt"]
    codefile: none
]

sourcecode: [
    origin 0x0 space 1x0
    below
    treepan: panel mainclr [
        below
        origin 0x0 space 0x0
        treebar: panel [
            origin 0x0 space 0x0
            treeclose: text "▾" 16 center font syswinfnt on-down [
                    closepanel treepan treebar face 196x0 196x211
                ] on-over [flashbutton face event]
            treelabel: text "Tree" 48 font syswinfnt on-up [
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

            treename: text "✏︎" 24 center font syswinfnt on-down [
                    sel: treelist/selected
                    if  (sel <> none) [
                        closemenu face does [
                            askuser/rename face "Rename" treelist/data/:sel
                        ]
                    ]
                ]

            treedel: text "⌫" 24 center font syswinfnt on-up[
                    sel: treelist/selected
                    if (sel <> none) [
                        closemenu face does [
                            askuser/del face "Remove" treelist/data/:sel
                        ]
                    ]
                ]

            treehide: text ".*" 24 center font syswinfnt on-down [
                    face/font/color: either hiddenfiles [
                        hiddenfiles: false
                        gray
                    ][
                        hiddenfiles: true
                        sysclr
                    ]
                    navigation
                ]
        ]

        treeask: panel 196x0 mainclr [
            origin 0x0 space 0x4
            below
            asktext: text "" 196 center font syswinfnt
            askinp: area 196x16 "" center dispclr no-border font syswinfnt
                on-key-down[
                    if event/key = 13 [
                        askfunc
                        linenum: linenum + 1
                        showline
                    ]
                    if event/key = 27 [askclose]
                ]
                yesbut: text "↳" 196 center font syswinfnt on-up [
                        face/font/color: sysclr
                        askfunc
                    ] on-down [face/font/color: gray
                    ] on-over [flashbutton face event]
        ]

        treespace: panel 196x211 dispclr [
            origin 0x0 space 0x1
            below
            treecli: field 196x16 no-border on-change [
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

            treelist: text-list 196x195 data [] no-border on-change [
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
        drawbar: panel [
            origin 0x0 space 0x0
            drawclose: text "▾" 16 center font syswinfnt on-down [
                clos: closepanel drawpan drawbar face 196x0 196x250
            ]on-over [flashbutton face event]
            drawlabel: text "Draw" 48 font syswinfnt

            drawnew: text "⊞" 24 center font syswinfnt extra "new" on-down [
                        face/font/color: gray
                    ] on-up [
                        canvas/draw: []
                        defimg: ifexist defimg
                        face/font/color: sysclr
                    ]
                on-over [
                    flashbutton face event
                ]
            drawsel: text "◰" 24 center font syswinfnt extra "sel"

            drawcell: text "⌗" 24 center font syswinfnt extra "cells" on-down[
                    cells/draw: either ((length? cells/draw) > 0)[
                        face/font/color: gray
                        []
                    ][
                        face/font/color: sysclr
                        updcells
                    ]
                ]

            drawdel: text "✄" 24 center font syswinfnt extra "del"
                on-down [
                    drawinst: face
                    face/font/color: either deletepixel [
                        deletepixel: false
                        sysclr
                    ][
                        fillpixel: false
                        drawfill/font/color: sysclr
                        deletepixel: true
                        gray
                    ]
                ]

            drawfill: text "▣" 24 center font syswinfnt
                on-down [
                    face/font/color: either fillpixel [
                        fillpixel: false
                        sysclr
                    ][
                        fillpixel: true
                        gray
                    ]
                ]
        ]

        drawmachine: panel 196x250 dispclr [
            origin 1x1 space 2x0

            do [setgrid]
            canvas: box 176x224 draw []
            at 1x1 cells: box 176x224 draw compose/deep/only grid all-over
                on-down [
                    if (drawinst) [
                        drawline: true
                        setpixel canvas event drawcolor
                    ]
                ]on-up [
                    if (drawinst) [ drawline: false]
                ]on-over [
                    if (drawinst) [
                        getinput: either (event/away?) [
                            deletepixel: false
                            drawdel/font/color: sysclr
                            false
                        ][
                            set-focus canvas
                            true
                        ]
                        if (drawline) [ setpixel canvas event drawcolor ]
                    ]
                ]

            style pxcolor: base 15x15  extra "color" on-down [
                            drawinst: face
                            drawcolor/color: face/color
                            face/color: gray

                        ] on-up [
                            face/color: drawcolor/color
                        ]
            colors: panel [
                below
                origin 0x0 space 0x1
                drawcolor: box 15x15 "?" transparent center font syswinfnt extra "picker" on-over [
                        flashbutton face event
                    ]
                pxcolor crimson
                pxcolor orange
                pxcolor leaf
                pxcolor khaki
                pxcolor navy
                pxcolor teal
                pxcolor sky
                pxcolor pink
                pxcolor gold
                pxcolor brown
                pxcolor gray
                pxcolor black
                pxcolor white
            ]

            return
            pad 0x4
            drawsave: text "↳" 196 center font syswinfnt extra "save" on-down [
                    newimg: make image! reduce [canvas/size transparent]
                    draw newimg compose/deep/only canvas/draw
                    save/as to-red-file defimg newimg 'png
                    navigation
                ]
                on-over [
                    flashbutton face event
                ]
        ]
    ] loose
    return

    style display: area 602x400 dispclr wrap font codefnt no-border
    style terminal: area 602x78 dispclr wrap font consfnt no-border
    style numbar: area 41x370 dispclr font codefnt font-color gray no-border

    codepan: panel mainclr[
        below
        origin 0x0 space 1x1
        codebar: panel [
            origin 0x0 space 0x0
            codeclose: text "▾" 16 center font syswinfnt on-down [
                closepanel codepan codebar face 602x0 602x480
            ]on-over [flashbutton face event]

            do [getinput: false]
            codelabel: text "Code" 48 font syswinfnt

            consolereset: text "↺" 24 center font syswinfnt on-up [
                face/font/color: sysclr
                build
            ]on-down [face/font/color: gray
            ]on-over [flashbutton face event]
            consoleloop: text "∞" 24 font syswinfnt on-down[
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
            codesavelab: text "" 24 font syswinfnt

            codefilelab: text "" 256 font syswinfnt font-color gray
        ]

        across
        ; codenumbers: numbar "" right disabled on-focus [
        ;     set-focus codemill]

        codemill: display "" focus font-color codeclr
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
                linenum: (mousepos/y / linehei)
                ; print [linenum codelines]
                if linenum >= (codelines) [
                    linenum: codelines - 1
                ]
                ; print linenum

                showline
            ]on-key-down[
                if (not codefile) [setfile deffile]
                switch event/key [
                    up [ if linenum > 0 [linenum: linenum - 1]
                        showline
                    ]
                    down [ if linenum < (codelines - 1) [linenum: linenum + 1]
                        showline
                    ]
                ]
                if event/key = 13 [
                    linenum: linenum + 1
                    showline
                ]
                deltalines: oldlines - codelines
                if (deltalines > 0) [
                    oldlines: codelines
                    linenum: linenum - deltalines
                    showline
                ]
            ]on-key-up[
                deltalines: oldlines - codelines
                if (deltalines > 0) [
                    oldlines: codelines
                    linenum: linenum - deltalines
                    showline
                ]

            ]on-unfocus [
                if not getinput [set-focus face]
            ]on-over[
            ]on-create [
                codefile: none
                initline

                codelines: shownumbers
                oldlines: codelines
            ]
        return

        at 0x0 flashlinetop: base 0x0 with [ size: as-pair codemill/size/x 1
                                        color: sysclr + 0.0.0.128]
        at 0x0 flashlinebot: base 0x0 with [ size: as-pair codemill/size/x 1
                                        color: sysclr + 0.0.0.128]
        below
        console: terminal "" font-color codeclr on-key-down[
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
        viewbar: panel [
            origin 0x0 space 0x0
            viewclose: text "▾" 16 center font syswinfnt on-down [
                closepanel viewpan viewbar face 640x0 640x480
            ]on-over [flashbutton face event]
            viewlabel: text "View" font syswinfnt
        ]
        viewengine: panel 640x480 dispclr
    ] loose
    return
]

; sourcecode EmptyCore

sourcecode: [
    origin 0x0 space 1x0
    below
    treepan: panel mainclr [
        below
        origin 0x0 space 0x0
        treebar: panel [
            origin 0x0 space 0x0
            treelabel: text "Tree" 48 font syswinfnt on-up [
                    face/font/color: sysclr
                    navdir: copy homedir
                    navigation
                ] on-down [face/font/color: gray
                ] on-over [flashbutton face event "Tree" "Home"]

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
                    ] on-over [flashbutton face event face/text face/text]
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
    ]


    drawpan: panel mainclr [
        below
        origin 0x0 space 0x0
        drawbar: panel [
            origin 0x0 space 0x0
            drawlabel: text "Draw" 48 font syswinfnt extra "new"
                on-down [
                    face/font/color: gray
                ] on-up [
                    newimage
                    face/font/color: sysclr
                ] on-over [flashbutton face event "Draw" "New"]

            drawpick: text "?" 24 center font syswinfnt extra "picker"
                on-down [
                    pickpixel: toolswitch face pickpixel
                    fillpixels: tooloff drawfill
                    delpixel: tooloff drawdel
                ]

            drawcells: text "⌗" 24 center font syswinfnt extra "cells"
                on-down[
                    cells/draw: either ((length? cells/draw) > 0)[
                        face/font/color: gray
                        []
                    ][
                        face/font/color: sysclr
                        updcells
                    ]
                ]

            drawrot: text "↻" 24 center font syswinfnt extra "rot"
                on-down [
                    face/font/color: gray
                ] on-up [
                    rotateimage canvas
                    face/font/color: sysclr
                ] on-over [flashbutton face event face/text face/text]

            drawdel: text "✄" 24 center font syswinfnt extra "del"
                on-down [
                    delpixel: toolswitch face delpixel
                    fillpixels: tooloff drawfill
                    pickpixel: tooloff drawpick
                ]

            drawfill: text "▣" 24 center font syswinfnt extra "fill"
                on-down [
                    fillpixels: toolswitch face fillpixels
                    delpixel: tooloff drawdel
                    pickpixel: tooloff drawpick
                ]

            drawundo: text "⇠" 24 center font syswinfnt extra "undo"
                on-down [
                    face/font/color: gray
                ] on-up [
                    undo: take/last undodraw
                    if (undo) [
                        drawmatrix: copy undo
                        drawpixels drawmatrix canvas
                    ]

                    face/font/color: sysclr
                ] on-over [flashbutton face event face/text face/text]
        ]

        drawmachine: panel 196x250 dispclr [
            origin 2x2 space 1x2
            canvas: box cansize draw []
            at 2x2 cells: box cansize draw [] all-over
                on-down [
                    if (drawinst) [
                        append/only undodraw copy drawmatrix
                        drawline: either fillpixels [false][true]
                        setpixel canvas event drawbrush drawmatrix

                        if (pickpixel) [
                            pickpixel: toolswitch drawpick pickpixel
                            drawinst: drawbrush
                        ]
                    ]
                ]on-alt-down [
                    delpixel: toolswitch drawdel delpixel
                    fillpixels: tooloff drawfill
                ]on-up [
                    if (drawinst) [drawline: false]
                ]on-over [
                    if (length? undodraw) > undosteps [take undodraw]
                    if (drawinst) [
                        getinput: either (event/away?) [
                            false
                        ][
                            set-focus canvas
                            true
                        ]
                        if (drawline) [
                            setpixel canvas event drawbrush drawmatrix
                        ]
                    ]
                ] on-create [
                    setgrid
                    updcells
                ]
            return
            style pxcolor: base 15x15 dispclr extra "color"
                on-down [
                    drawinst: drawbrush
                    drawbrush/color: face/color
                    face/color: gray
                ] on-up [
                    face/color: drawbrush/color
                    delpixel: tooloff drawdel
                ] on-alt-down [
                    face/color: drawbrush/color
                ]

            style sl: slider 76x16 0% [
                drawbrush/color: percent-torgba R/data G/data B/data A/data
            ]
            at 2x122 drawsliders: panel 95x72 dispclr [
                origin 1x1 space 1x2
                below
                drawred: base 16x16 "R" center transparent font syswinfnt
                drawgreen: base 16x16 "G" center transparent font syswinfnt
                drawblue: base 16x16 "B" center transparent font syswinfnt
                drawalpha: base 16x16 "𝞪" center transparent font syswinfnt
                return
                R: sl
                G: sl
                B: sl
                A: sl 100%
            ]
            do [drawsliders/visible?: false]

            colors: panel [
                across
                origin 0x0 space 1x1
                drawbrush: base 15x15  "☄︎" center font syswinfnt extra "color"
                    on-down [
                        drawinst: face
                        delpixel: tooloff drawdel

                        either drawsliders/visible? [
                            drawsliders/visible?: false
                        ][
                            drawsliders/visible?: true
                        ]
                    ]
                do [
                    drawbrush/color: percent-torgba R/data G/data B/data A/data
                ]

                pxcolor crimson
                pxcolor brick
                pxcolor orange
                pxcolor leaf
                pxcolor teal
                pxcolor mint
                pxcolor navy
                pxcolor reblue
                pxcolor aqua
                pxcolor purple
                pxcolor violet
                return
                pxcolor sky
                pxcolor pink
                pxcolor gold
                pxcolor brown
                pxcolor sienna
                pxcolor olive
                pxcolor silver
                pxcolor pewter

                pxcolor gray
                pxcolor coal
                pxcolor black
                pxcolor white
            ]

            return
            pad 0x1
            drawsave: text "✚ᐩ" 95 mainclr center font syswinfnt
                on-down [
                    file: ifexist defimg
                    editimg: file
                    saveimage file
                ]
                on-over [
                    flashbutton face event face/text face/text
                ]
            drawoverwrite: text "↳" 95 mainclr center font syswinfnt
                on-down [
                    if (editimg) [saveimage editimg]
                ]
                on-over [
                    flashbutton face event face/text face/text
                ]
        ] on-create [newimage]
    ]
    return

    style display: area 602x400 dispclr wrap font codefnt no-border
    style terminal: area 602x78 dispclr wrap font consfnt no-border
    style numbar: area 41x370 dispclr font codefnt font-color gray no-border

    codepan: panel mainclr[
        below
        origin 0x0 space 1x1
        codebar: panel [
            origin 0x0 space 0x0
            do [getinput: false]
            codelabel: text "Code" 48 font syswinfnt on-up [
                face/font/color: sysclr
                build
            ]on-down [face/font/color: gray
            ]on-over [flashbutton face event "Code" "Run"]

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
    ]
    return
    viewpan: panel mainclr [
        below
        origin 0x0 space 0x0
        viewbar: panel [
            origin 0x0 space 0x0
            viewlabel: text "View" 48 font syswinfnt
        ]
        viewengine: panel 640x480 dispclr
    ]
    return
]

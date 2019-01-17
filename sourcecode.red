sourcecode: [
    origin 0x0 space 2x0
    style display: area dispclr wrap font-name "Andale Mono" no-border
    style numbar: area dispclr font-name "Andale Mono" font-size 10 font-color gray no-border
    below
    panel [
        do [getinput: false]
        below
        origin 0x0 space 1x0
        codelabel: text "CodeMill" font syswinfont
        across

        codenumbers: numbar "1" right 42x370 on-focus [set-focus codemill]
        do [
            scroller: get-scroller codenumbers 'vertical
            scroller/visible?: false
        ]
        codemill: display "" focus 550x370 font-size 10 font-color codeclr on-change [
                getinput: false
                newline: "^/"

                numbers: do [split face/text newline]
                clear codenumbers/text
                i: 0
            foreach stroke numbers [
                i: i + 1
                append codenumbers/text rejoin [i newline]
            ]

            defcom: replace/all copy codemill/text "print" {append append terminal/text newline form reduce}
            defcom: replace/all defcom "prin" {append append terminal/text to string! reduce}
            defcom: replace/all defcom "probe" {append append terminal/text newline form}
            defcom: replace/all defcom "input" {view [do[getinput: true set-focus terminal]]}
            defcom: replace/all defcom "ask" {view [do[getinput: true set-focus terminal]]}

            ; view output
            docom: string!
            viewcom: find defcom "view ["

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
            attempt [do defcom]
            ; add newline when getinput
            if getinput [terminal/text: rejoin [terminal/text newline]]

            textsize: size-text face
            ; overflow: face/size - textsize
            ; print overflow
            print textsize
            ; print [offset-to-caret face textsize]
            ; codenumbers/selected: 1x10
            ; print face/offset

            ; print codenumbers/offset/y: -19
        ] on-over[

        ]on-unfocus [if not getinput [set-focus face]]
        return
        below
        terminallabel: text "Terminal" font syswinfont
        terminal: display "" 593x104 font-size 9 font-color codeclr on-key-down [
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
    panel [
        below
        origin 0x0 space 0x0
        viewlabel: text "ViewEngine" font syswinfont
        viewengine: panel 512x512 dispclr
    ] loose
    return
    panel [
        below
        origin 0x0 space 0x0
        drawlabel: text "DrawMachine" font syswinfont
        drawmachine: panel 256x256 dispclr
    ] loose

    panel [
        below
        origin 0x0 space 0x0
        iolabel: text "IO" font-color sysclr
        iospace: panel 256x256 dispclr
    ] loose
]

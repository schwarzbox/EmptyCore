; sourcefunc EmptyCore

do [
    closepanel: function [pan bar face low high][
        result: either face/text = "▾" [
            face/text: "▸"
            low
        ][
            face/text: "▾"
            high
        ]
        pan/size/y: either (result/y = 0)[
            bar/size/y
        ][
            (bar/size/y + result/y)
        ]
    ]

    closemenu: func [face action][
        either askopen [
            either askopen/text <> face/text [
                askclose
                action
                face/font/color: gray
            ][
                askclose
                face/font/color: sysclr
            ]
        ][
            action
            face/font/color: gray
        ]
    ]

    flashbutton: function [face event][
        either event/away?[
            face/font/color: sysclr
        ][
            face/font/color: sysclr + extralight
        ]
    ]

    navigation: does [
        dirlist: copy read/lines navdir
        if not hiddenfiles [
            remove-each file dirlist [(first file) = #"." ]
        ]
        if (first dirlist) = "" [take dirlist]
        if navdir <> %"/" [insert dirlist ".."]
        treelist/data: sort dirlist

        ; add for treecli
        spl: split-path navdir
        either spl/2 [
            treecli/data: rejoin [spl/2 " >"]
        ][
            treecli/data: rejoin [spl/1 " >"]
        ]
    ]

    autosave: does [
        if codefile [write codefile codemill/text codesavelab/text: "●"]]

    shownumbers: does [
        ; error line?
        numbers: split codemill/text newline
        ; clear codenumbers/text
        i: 0
        foreach stroke numbers [
            i: i + 1
            ; append codenumbers/text rejoin [i newline]
        ]
        return i
    ]

    initline: does [
        linenum: 0
        panhei: pick size-text codelabel 2
        codemilltext: codemill/text
        codemill/text: "⚛︎"
        deltasize: 4
        if (codemill/font/size % 4) = 0 [deltasize: 3]
        linehei: (pick size-text codemill 2) - deltasize
        codemill/text: codemilltext
        showline
    ]

    showline: does[
        flashlinetop/offset: as-pair 0 (panhei + (linenum * linehei))
        flashlinebot/offset: as-pair 0 (panhei + (linenum * linehei) + linehei)
    ]

    openfile: func [file][
        autosave
        spl: split-path file
        namelab: copy form spl/2
        codefilelab/text: namelab
        codefile: copy file
        codemill/text: read codefile

        linenum: shownumbers - 1
        showline
        codesavelab/text: "●"
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
            set-focus codemill
        ]
    ]

    setfile: func [name] [
        if name [
            file: copy either find name "." [name][rejoin [name ".red"]]
            file: ifexist file
            write file "#!/usr/bin/env red^(line)Red [Needs: View]^(line)"
            openfile file
            navigation
            set-focus codemill
        ]
    ]

    setname: func [name][

        if (name <> none) [
            oldfile: to-red-file treelist/data/:sel
            tmpfile: read oldfile
            either isfile oldfile [
                rmrf oldfile
                file: either find name "." [name][rejoin [name ".red"]]
                file: ifexist file
                write to-red-file file tmpfile
                openfile file
            ][
                rmrf oldfile
                make-dir to-red-file dirize name
            ]
            navigation
            set-focus codemill
        ]
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
                ; clear codenumbers/text
                clear console/text
                clear codefilelab/text
                clear codesavelab/text
                linenum: shownumbers - 1
                showline
                codefile: none
            ]
        ]
        delete file
    ]

    askclose: does [
        foreach askbutton [treedir treefile treename treedel][
            do rejoin[ askbutton "/font/color: sysclr"]
        ]
        askopen: none
        asktext/text: ""
        askinp/text: ""
        askinp/selected: 1x0
        treeask/size: 196x0
        treespace/offset: treespace/offset - 0x64
        navigation
    ]

    askuser: func [face txt name /folder /file /rename /del][
        askopen: face
        treeask/size: 196x64
        treespace/offset: treespace/offset + 0x64
        asktext/text: copy form txt
        askinp/text: copy form name

        if folder [askfunc: does [setdir askinp/text askclose]]
        if file [askfunc: does [setfile askinp/text askclose]]
        if rename [askfunc: does [setname askinp/text askclose]]
        if del [askfunc: does [delfile askinp/text askclose]]

        either del [
            askinp/enabled?: false
        ][
            askinp/enabled?: true
            set-focus askinp

        ]
        askinp/font: syswinfnt
        navigation
    ]

    isfile: func [sel][
        if not dir? to-red-file sel [
            file: copy to-red-file rejoin [navdir sel]
            if find codext form suffix? sel [
                openfile file
                return true
            ]
            if find imgext form suffix? sel [

            ]
            if ((first sel) = #".") and ((second sel) <> #".")[
                openfile file
                return true
            ]
            if (find sel #".") = none [
                openfile file
                return true
            ]
            return false
        ]
        return false
    ]

    isback: func [sel] [
        if sel = ".." [
            spl: split-path navdir
            if spl [
                change-dir spl/1
                navdir: to-red-file get-current-dir
                navigation
            ]

        ]
    ]

    isdir: func[sel][
        if (last sel) = #"/" [
            change-dir rejoin [navdir sel]
            navdir: to-red-file get-current-dir
            navigation
        ]
    ]

    treecom: does [
        path: to-red-file find/tail treecli/text ">"
        either (dir? path)[
            fullpath: rejoin [navdir path]
            case [
                (exists? path) [navdir: copy normalize-dir path]
                (exists? fullpath) [navdir: copy normalize-dir fullpath]
            ]
            navigation
        ][
            if exists? path [isfile path]
        ]
    ]

    setgrid: func [] [
        grid: [pen (sysclr + 0.0.0.196)
                            line-width 1
                            line 0x0 175x0
                            line 0x0  0x223]
        horgr: 0x7 loop 28 [
            append grid compose [line (horgr) (175x0 + horgr)]
            either ((horgr / 8) % 6 = 0x0) [
                append grid compose [pen (sysclr + 0.0.0.128)]
            ][
                append grid compose [pen (sysclr + 0.0.0.196)]
            ]
            horgr: horgr + 0x8

        ]
        vergr: 7x0 loop 22 [
            append grid compose [line (0x223 + vergr) (vergr)]
            either ((vergr / 8) % 6 = 0x0) [
                append grid compose [pen (sysclr + 0.0.0.128)]
            ][
                append grid compose [pen (sysclr + 0.0.0.196)]
            ]
            vergr: vergr + 8x0
        ]
    ]

    updcells: does [cells/draw: compose/deep/only grid]

    getcolor: function [face ispixel] [
        if (ispixel) [
            cellcolor: (index? ispixel) - 4
            pick face/draw cellcolor
        ]
    ]

    rmpixel: function [face ispixel] [
        if (ispixel) [
            deletestart: (index? ispixel) - 6
            remove/part skip face/draw deletestart 7
        ]
    ]

    updpixel: function [face ispixel brush pxstart pxsize][
        rmpixel face ispixel
        append face/draw compose/deep/only [
            pen (brush/color) fill-pen (brush/color)
            box (pxstart) (pxsize)]
    ]

    colorwave: function [face defclr brush pxstart pxsize pass][
        if (pxstart < 0x0) or (pxstart > 176x224 ) [print "exit" exit]

        foreach px [0x-8 8x-8 8x0 8x8 0x8 -8x8 -8x0 -8x-8][
            nextpixel: find face/draw (pxstart + px)
            curclr: getcolor face nextpixel
            ; print [(pxstart + px)]
            if (defclr = curclr) and (not (find pass (pxstart + px))) [

                updpixel face nextpixel brush (pxstart + px) (pxsize + px)

                append pass compose [(pxstart + px)]
                colorwave face defclr brush (pxstart + px) (pxsize + px) pass
            ]
        ]
    ]

    setpixel: function [face event brush] [
        pxstart: (event/offset / 8x8) * 8x8
        pxsize: pxstart + 8x8 - 1
        ispixel: find face/draw pxstart
        case [
            (drawinst/extra = "color") [
                ; print [length? face/draw]
                updpixel face ispixel brush pxstart pxsize
                ; if (fillpixel) [
                ;     drawline: false
                ;     defclr: getcolor face ispixel
                ;     colorwave face defclr brush pxstart pxsize copy []
                ; ]
            ]
            (drawinst/extra = "del") [ rmpixel face ispixel ]
        ]
    ]

    print: func [argument [default!]][
        append append console/text form reduce argument newline
        return reduce argument
    ]

    ; prin: func [argument [default!]][
    ;     append console/text form reduce argument
    ;     return reduce argument
    ; ]

    probe: func [argument [default!]][
        append append console/text form argument newline
        return argument
    ]

    View: func [argument [block!]][
        safecall [viewengine/pane: layout/only load mold argument]
    ]

    ; WIP
    input: func [][
        getinput: true
        append console/text " "
        set-focus console
        ; while [getinput] [wait 0.1 print ]
        ret: take/last userinput
        ret: either ret [ret][""]
        return ret
    ]

    ask: func [question [string!]][
        getinput: true
        append append console/text question " "
        set-focus console
        return last userinput
    ]
    ; WIP
    ; do [defabout: 'about]
    ; about: does[
    ;     defabout
    ; ]

    ; do [defhelp: get 'help]
    ; help: func [argument [any-type!]][
    ;     append console/text form (defhelp argument)
    ;     return true
    ; ]

    build: does [
        autosave
        run: autorun
        if run [autorun: true]
        execute codemill
        autorun: run
    ]

    safecall: func [command][
        either showerror [
            ; error?
            if error? try command [print ["^/" try command ]]
        ][attempt command]
    ]

    execute: func [face] [
        getinput: false
        ; console output
        console/text: rejoin ["Red " form system/version newline]
        ; avoid to run #!
        either find/match codemill/text "#!" [
            maincom: copy find/tail codemill/text newline
        ][
            maincom: copy codemill/text
        ]
        ; avoid to run Red []
        either find/case maincom "Red" [
            maincom: copy find/tail maincom "]"
        ][
            maincom: copy codemill/text
        ]
        ; avoid q programm
        if not maincom = "^/q" [
            safecall [do maincom]
        ]
    ]
]

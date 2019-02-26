; sourcefunc EmptyCore

do [
    closepanel: function [txt low high][
        either txt = "▾" [
            txt: "▸"
            return compose [(txt) (low)]
        ][
            txt: "▾"
            return compose [(txt) (high)]
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
        clear codenumbers/text
        i: 0
        foreach stroke numbers [
            i: i + 1
            append codenumbers/text rejoin [i newline]
        ]
        return i
    ]

    initline: does [
        linenum: 0
        panhei: pick size-text codelabel 2
        linehei: panhei - 4
        showline
    ]

    showline: does[
        flashline/offset: as-pair 0 (panhei + (linenum * linehei))
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
                clear codenumbers/text
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
        treeask/size: 256x0
        treespace/offset: treespace/offset - 0x64
        navigation
    ]

    askuser: func [face txt name /folder /file /rename /del][
        askopen: face
        treeask/size: 256x64
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
            if find extensions form suffix? sel [
                openfile file
                return true
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

    print: func [argument [default!]][
        append append console/text form reduce argument newline
        return reduce argument
    ]

    prin: func [argument [default!]][
        append console/text form reduce argument
        return reduce argument
    ]

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

; sourcefunc EmptyCore

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

    filedir: []
    foreach fl sort read navdir [
        if find fl "/" [take/last fl]
        append filedir fl
    ]

    while [(find filedir to-red-file file)] [
        num: form i
        i: i + 1
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
        old: to-red-file treelist/data/:sel
        fileold: isfile old
        case [
            fileold  = "code" [
                tmpfile: read old
                rmrf old
                file: either find name "." [name][rejoin [name ".red"]]
                file: ifexist file
                write to-red-file file tmpfile
                openfile file
                set-focus codemill
            ]
            fileold  = "img"[
                tmpfile: read/binary old
                rmrf old
                file: either find name "." [name][rejoin [name ".png"]]
                file: ifexist file
                write/binary to-red-file file tmpfile
            ]
            fileold = "dir" [
                rmrf old
                make-dir to-red-file dirize name
            ]
        ]
        navigation
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


isfile: func [sel] [
    if not dir? to-red-file sel [
        file: copy to-red-file rejoin [navdir sel]

        if find codext form suffix? sel [
            openfile file
        ]
        if find imgext form suffix? sel [
            loadimage file
            return "img"
        ]
        fileexist: ((find (sort read navdir) sel) <> none)
        if ((first sel) = #".") and ((second sel) <> #".") and fileexist [
            openfile file
        ]
        if ((find sel #".") = none) and fileexist [
            openfile file
        ]
        return "code"
    ]
    return "dir"
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
    grid: [pen (sysclr + 0.0.0.196) line-width 1]
    horline: 0x7 loop 24 [
        append grid compose [line (horline) (191x0 + horline)]
        either ((horline / 8) % 5 = 0x0) [
            append grid compose [pen (sysclr + 0.0.0.128)]
        ][
            append grid compose [pen (sysclr + 0.0.0.196)]
        ]
        horline: horline + 0x8
    ]
    verline: 7x0 loop 24 [
        append grid compose [line (0x191 + verline) (verline)]
        either ((verline / 8) % 5 = 0x0) [
            append grid compose [pen (sysclr + 0.0.0.128)]
        ][
            append grid compose [pen (sysclr + 0.0.0.196)]
        ]
        verline: verline + 8x0
    ]
]

newimage: does [
    if (length? drawmatrix) > 0 [saveimage defimg]
    newimg: make image! reduce [canvas/size transparent]
    fillmatrix newimg
    drawpixels drawmatrix canvas
]

loadimage: func[file] [
    newimg: make image! reduce [canvas/size transparent]
    loadimg: load file
    draw newimg compose/deep/only [image (loadimg)]
    fillmatrix newimg
    drawpixels drawmatrix canvas
]

rotateimage: func[canvas] [
    newimg: make image! reduce [canvas/size transparent]
    draw newimg compose/deep/only canvas/draw
    rotimg: make image! reduce [canvas/size transparent]
    draw rotimg  compose/deep/only [rotate 90 (canvas/size / 2) image (newimg)]
    fillmatrix rotimg
    drawpixels drawmatrix canvas
]

saveimage: func [defimg][
    newimg: make image! reduce [canvas/size transparent]
    draw newimg compose/deep/only canvas/draw
    file: ifexist defimg
    save/as to-red-file file newimg 'png
    navigation
]

fillmatrix: func[img][
    drawmatrix: copy[]
    y: 0
    while [y < img/size/y][
        x: 0
        while [x < img/size/x] [
            ; take color in center
            index: x + (y * img/size/x) + (pxsize/x / 2)
            clr: img/:index
            st: ((as-pair x y) * pxsize) / pxsize
            sz: (st + pxsize) - 1
            append drawmatrix compose [(st) (sz) (clr)]
            x: x + pxsize/x
        ]
        y: y + pxsize/y
    ]
]

updcells: does [cells/draw: compose/deep/only grid]

getcolor: function [drawmatrix pixel] [
    if (pixel) [
        cellcolor: (index? pixel) + 2
        pick drawmatrix cellcolor
    ]
]

rmpixel: function [drawmatrix pixel] [
    if (pixel) [
        delstart: (index? pixel) - 1
        remove/part skip drawmatrix delstart 3
    ]
]

updpixel: function [drawmatrix pixel color pxstart pxsize][
    rmpixel drawmatrix pixel
    append drawmatrix compose [(pxstart) (pxsize) (color)]
]

tooloff: function [face][
    face/font/color: sysclr
    false
]

closepixels: function [drawmatrix defclr color pxstart pxfin pass][
    foreach px [0x-8 8x-8 8x0 8x8 0x8 -8x8 -8x0 -8x-8][
        pixst: pxstart + px
        pixsz: pxfin + px
        if (pixst/x < 0) or (pxfin/x > 256) [continue]
        if (pixst/y < 0) or (pxfin/y > 256) [continue]
        if (find/only pass compose [(pixst) (pixsz)]) [continue]

        nextpixel: find drawmatrix pixst
        curclr: getcolor drawmatrix nextpixel
        if (defclr = curclr) [
            updpixel drawmatrix nextpixel color pixst pixsz
            append pass compose/deep [[(pixst) (pixsz)]]
        ]
    ]
]

fillwave: function [drawmatrix defclr color pxstart pxfin][
    pass: copy compose/deep [[(pxstart) (pxfin)]]
    i: 0
    while [(length? pass) > 0][
        closepixels drawmatrix defclr color pass/1/1 pass/1/2 pass
        take pass
        i: i + 1
    ]
]

setpixel: function [canvas event brush drawmatrix] [
    pxstart: (event/offset / 8x8) * 8x8
    pxfin: pxstart + 8x8 - 1
    pixel: find drawmatrix pxstart
    defclr: getcolor drawmatrix pixel
    case [
        (drawinst/extra = "color") or (drawinst/extra = "picker") [
            if (defclr <> brush/color) [
                updpixel drawmatrix pixel brush/color pxstart pxfin
                if (fillpixels) [
                    fillwave drawmatrix defclr brush/color pxstart pxfin
                ]
            ]
        ]
        (drawinst/extra = "del") [
            updpixel drawmatrix pixel transparent pxstart pxfin
        ]
    ]
    drawpixels drawmatrix canvas
]

drawpixels: function [drawmatrix canvas] [
    canvas/draw: copy []
    drawcom: copy []

    foreach [st sz clr] drawmatrix [
        append drawcom compose [pen (clr) fill-pen (clr) box (st) (sz)]
    ]
    append/only canvas/draw drawcom
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
    append append console/text mold argument newline
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


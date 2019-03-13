#!/usr/bin/env red

; EmptyCore.red

; MIT License
; Copyright (c) 2019 Alexander Veledzimovich veledz@gmail.com

; Permission is hereby granted, free of charge, to any person obtaining a
; copy of this software and associated documentation files (the "Software"),
; to deal in the Software without restriction, including without limitation
; the rights to use, copy, modify, merge, publish, distribute, sublicense,
; and/or sell copies of the Software, and to permit persons to whom the
; Software is furnished to do so, subject to the following conditions:

; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
; DEALINGS IN THE SOFTWARE.

Red [
    File: %EmptyCore.red
    Title: "EmptyCore"
    Author: "Alexander Veledzimovich"
    Version: 0.1
    Date: "2019"
    Rights: "(c) Alexander Veledzimovich"
    License: "MIT"
    Needs: View
]
; 🧩 ⚙️  ▦□ ⧈ ◱ ◰ ⧉ ⸬ ▨ ⬚ 𖣯▦⊞
; all var stay forever?

; 0.4

; improve lines
; rename png in same ext block

; load and edit
; loop color

; change CLI on area

; add move handlers

; improve fill
; selector image
; save selector
; resize image
; color picker


; save user setup and load after main setup

; focus on list for dir and show created file and dir
; func fold button for panels use constants sizes (change sizes with font)

; 0.5
; refactor vars and show all source code (use with compose)

; ask input loop pause

; 0.6

; theme rtf color for syntax native mezanine

; project compile
; final project window

; v0.6
; resize panels
; scrool numbers
; improve delete code lines
; add rectangle and circle tool

; error line
; tabs

; ? ?? help what about
; import modules

system/view/auto-sync?: yes

; constants
⌘: false
leftshift: false

; save View
ViewRed: get 'View
; support function
do read %sourcefunc.red
; load sourcecode
do read %sourcecode.red
maincode: mold sourcecode

; WIP
; userset
; if not find (sort read %..) userset

; do read %userset.red
; usercode: mold sourcecode

backclr: 16.16.16.0
mainclr: tuple!
dispclr: tuple!
codeclr: tuple!
sysclr: tuple!

uicolors: block!
uifonts: block!

colors: [
    Core: [
        main: 32.32.32.0
        disp: 42.42.42.0
        code: 222.222.222.0
        system: 32.196.255.0
    ]
]
fonts: [
    Andale: [name "Andale Mono" size 10]
]

set-scheme: func [schemeclr schemefnt schemesize] [
    foreach file read %.. [
        if file = "scheme.red" [do read %../scheme.red]
    ]
    uicolors: copy []
    foreach clr colors [
        if (type? clr) = set-word! [append uicolors form clr]
    ]
    uifonts: copy []
    foreach fnt fonts [
        if (type? fnt) = set-word! [append uifonts form fnt]
    ]
    mainclr: do rejoin["colors/" schemeclr "/main"]
    dispclr: do rejoin["colors/" schemeclr "/disp"]
    codeclr: do rejoin["colors/" schemeclr "/code"]
    sysclr: do rejoin["colors/" schemeclr  "/system"]

    tmpfnt: do rejoin["fonts/" schemefnt]
    tmpsize: to-integer schemesize
    syswinfnt: make font! [name: tmpfnt/name
                        style: [regular] size: 10 color: sysclr]

    codefnt: make font! [name: tmpfnt/name
                            style: [regular] size: tmpsize  color: codeclr]
    consfnt: copy codefnt
    consfnt/size: codefnt/size - 1
]

apply-scheme: does  [
    syswin/color: dispclr
    syswinfnt/color: sysclr
    sysbut/font: copy syswinfnt
    syspan/color: mainclr

    syswin/font: syswinfnt
    syslab/font: syswinfnt
    sysopt/color: dispclr
    schemelab/font: syswinfnt
    schemefont/font: syswinfnt
    schemesize/font: syswinfnt

    codemill/color: dispclr
    ; codenumbers/color: dispclr
    console/color: dispclr
    viewengine/color: dispclr
    drawmachine/color: dispclr
    treespace/color: dispclr

    codelabel/font: copy syswinfnt
    viewlabel/font: copy syswinfnt
    drawlabel/font: copy syswinfnt
    treelabel/font: copy syswinfnt

    codesavelab/font: copy syswinfnt

    consolecol: consoleloop/font/color
    consoleloop/font: copy syswinfnt
    if consolecol = gray [consoleloop/font/color: consolecol]
    consolereset/font: copy syswinfnt
    flashlinetop/color: sysclr + 0.0.0.128
    flashlinebot/color: sysclr + 0.0.0.128


    treedir/font: copy syswinfnt
    treefile/font: copy syswinfnt
    treename/font: copy syswinfnt
    treedel/font: copy syswinfnt

    treecol: treehide/font/color
    treehide/font: copy syswinfnt
    if treecol = gray [treehide/font/color: treecol]

    treeask/color: mainclr
    askinp/color: dispclr
    asktext/font: copy syswinfnt
    askinp/font: copy syswinfnt
    yesbut/font: copy syswinfnt

    drawnew/font: copy syswinfnt
    drawsel/font: copy syswinfnt
    drawcell/font: copy syswinfnt
    drawdel/font: copy syswinfnt
    drawfill/font: copy syswinfnt
    drawcolor/font: copy syswinfnt
    drawsave/font: copy syswinfnt
    setgrid
    updcells

    codeclose/font: copy syswinfnt
    viewclose/font: copy syswinfnt
    drawclose/font: copy syswinfnt
    treeclose/font: copy syswinfnt

    codepan/color: mainclr
    viewpan/color: mainclr
    drawpan/color: mainclr
    treepan/color: mainclr

    codefnt/color: codeclr
    consfnt/color: codeclr
    consfnt/size: codefnt/size - 1
    codemill/font: copy codefnt
    console/font: copy consfnt
    ; codenumbers/font: copy codefnt
    ; codenumbers/font/color: gray
    codefilelab/font: copy syswinfnt
    codefilelab/font/color: gray
]

upd-scheme: does [
    attempt [livewin/pane: layout/only load syswin/text]
]

set-scheme "Core" "Andale" 10
livewin-wh: 1440x500
syswin-wh: as-pair (livewin-wh/x - 196) 256
sysclose-wh: 0x256


Core: [
    title "⚛︎ EmptyCore v0.36"
    backdrop backclr
    origin 0x0 space 1x0
    style display: area dispclr wrap font syswinfnt no-border

    below

    livewin: panel livewin-wh backclr []
    across

    syspan: panel mainclr[
        origin 0x0 space 1x0
        panel [
            origin 0x0 space 0x0

            sysbut: text "▾" 16 center font syswinfnt on-down [
                                    face/selected: true
                                    either face/text = "▾" [
                                        face/text: "▸"
                                    ][
                                        face/text: "▾"
                                    ]
                                ] on-over [flashbutton face event]
            syslab: text "Source" font syswinfnt
        ]
        return

        syswin: display maincode syswin-wh on-change [
            upd-scheme
        ]

        sysopt: panel 196x256 dispclr [
            origin 0x2 space 0x0
            schemelab: text "Scheme" font syswinfnt
            colorlist: drop-list  data uicolors on-change [
                                        set-scheme face/text fontlist/text sizelist/text
                                        apply-scheme
                                    ]on-create [
                                        face/selected: 1
                                        face/text: pick face/data face/selected
                                    ]
            return
            schemefont: text "Font" font syswinfnt
            fontlist: drop-list  data uifonts on-change [
                                        set-scheme colorlist/text face/text sizelist/text
                                        apply-scheme
                                    ]on-create [
                                        face/selected: 1
                                        face/text: pick face/data face/selected
                                    ]
            return
            schemesize: text "Size" font syswinfnt
            sizelist: drop-list data ["10" "11" "12" "13" "14"] on-change [
                                        set-scheme colorlist/text fontlist/text face/text
                                        codefnt/size: to-integer pick face/data face/selected
                                        apply-scheme
                                        initline
                                    ]on-create [
                                        face/selected: 1
                                        face/text: pick face/data face/selected
                                    ]
        ]
        do[upd-scheme]
    ]loose
]
ViewRed/options/flags layout Core [
        offset: 0x0
        ; offset: as-pair (livewin-wh/x - 640) 544
        actors: object [
            on-key-down: func [face event][
                ; escape 27
                ; delete 8
                if (⌘) [
                    case [
                        event/key = #"Q" [autosave unview quit]
                        ((event/key = #"N") and (not askopen)) [
                            closemenu treefile does [
                                askuser/file treefile "Create File" deffile]
                        ]
                        event/key = 8 [
                            sel: treelist/selected
                            if (codefile) [
                                spl: split-path codefile
                                closemenu treedel does [
                                    askuser/del treedel "Remove" spl/2]
                            ]
                        ]
                        event/key = #"S" [autosave]
                        event/key = #"B" [build]
                    ]
                ]
                if (form event/key) = "left-command" [⌘: true]
                if (form event/key) = "left-shift" [leftshift: true]
            ] on-key-up: func [face event][
                if (form event/key) = "left-command" [⌘: false]
                if (form event/key) = "left-shift" [leftshift: false]
            ] on-close: func [face event][autosave]
            on-up: func[face event][
                if sysbut/selected [
                    face/size: either sysbut/text = "▸" [face/size - sysclose-wh
                                        ][face/size + sysclose-wh]
                    sysbut/selected: none
                ]
            ]
        ]
    ][no-min]


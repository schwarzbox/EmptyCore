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

; all var stay forever?

;v0.4
; spaces in names
; arrow nav
; field color cursor
; scrool numbers and problem with less lines

; close button file?
; tab to nav panel autocomplete
; nav every loop?

; source button with arrow 🧩 ⚙️ 🎬 ⚠️  📂 ⚗︎ ␛
; refactor vars and show all source code
; func fold button for panels use constants sizes
; resize panels
; user font panel

; save editor state for all panels separate default and and user setup

; 0.5
; check quotes print prin view probe input ask!
; improve ask and input in loop change val

; update view problem react (use modal window?)
; same color change for all apply-scheme or reacors
; theme rtf color for syntax native mezanine

; v0.5
; make modules draw
; save images

; v0.6
; error line

system/view/auto-sync?: yes

; constants
⌘: false
leftshift: false
; load editable sourcecode
do read %sourcecode.red
code: mold sourcecode

backclr: 16.16.16
mainclr: tuple!
dispclr: tuple!
codeclr: tuple!
sysclr: tuple!

uicolors: block!
uifonts: block!

colors: [
    Core: [
        main: 32.32.32
        disp: 42.42.42
        code: 222.222.222
        system: 32.196.255
    ]
]
fonts: [
    Andale: [name "Andale Mono" size 10]
]

set-scheme: func [schemeclr schemefnt] [
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

    syswinfnt: make font! [name: tmpfnt/name
                        style: [regular] size: tmpfnt/size color: sysclr]

    sysbarfnt: make font! [name: "Monaco"
                        style: [regular] size: 16 color: sysclr]
]

apply-scheme: func []  [
    askclose
    syswin/color: dispclr
    syswinfnt/color: sysclr
    syswin/font: syswinfnt
    sysbar/color: mainclr

    sysbarfnt/color: sysclr
    sysbut/font: sysbarfnt
    ; syspan/color: dispclr
    ; schemelab/font: syswinfnt
    ; schemefont/font: syswinfnt

    codemill/color: dispclr
    codenumbers/color: dispclr
    console/color: dispclr
    viewengine/color: dispclr
    drawmachine/color: dispclr
    treespace/color: dispclr

    codelabel/font: syswinfnt
    consolelabel/font: syswinfnt
    viewlabel/font: syswinfnt
    drawlabel/font: syswinfnt
    treelabel/font: syswinfnt

    consolecol: consolebut/font/color
    consolebut/font: copy syswinfnt
    if consolecol = gray [consolebut/font/color: consolecol]
    consolereset/font: syswinfnt

    treedir/font: syswinfnt
    treefile/font: syswinfnt
    treename/font: syswinfnt
    treedel/font: syswinfnt

    treecol: treehide/font/color
    treehide/font: copy syswinfnt
    if treecol = gray [treehide/font/color: treecol]

    codeclose/font/color: sysclr
    consoleclose/font/color: sysclr
    viewclose/font/color: sysclr
    drawclose/font/color: sysclr
    treeclose/font/color: sysclr

    codepan/color: mainclr
    consolepan/color: mainclr
    viewpan/color: mainclr
    drawpan/color: mainclr
    treepan/color: mainclr

    codemill/font/color: codeclr
    console/font/color: codeclr
]

set-scheme "Core" "Andale"
syswin-wh: 1154x256
sysbar-wh: as-pair (syswin-wh/x + 256) 23
sysbut-wh: 48x24
sysclose-wh: 0x256
livewin-wh: as-pair (syswin-wh/x + 256) 512
sysclose: true

Core: [
    title "EmptyCore"
    backdrop backclr
    origin 0x0 space 1x0
    style display: area dispclr wrap font syswinfnt no-border

    below
    livewin: panel livewin-wh
    across
    sysbar: panel sysbar-wh mainclr [
        origin 0x1 space 0x0
        sysbut: button "⚛︎" sysbut-wh font sysbarfnt on-click [
                                sysclose: not sysclose
                            ] on-over [
                                face/selected: either event/away? [none][true]
                            ]
    ]react []

    return
    syswin: display code syswin-wh on-change [
        ; avoid delete content selected file when reload source code
        attempt [livewin/pane: layout/only load face/text]
    ]

    syspan: panel 256x256 dispclr [
        origin 0x2 space 0x0
        schemelab: text "Scheme" font syswinfnt react [face/font: syswin/font]
        colorlist: drop-list  data uicolors on-change [
                                    set-scheme face/text fontlist/text
                                    apply-scheme
                                ]on-create [
                                    face/selected: 1
                                    face/text: pick face/data face/selected
                                ]
        return
        schemefont: text "Font" font syswinfnt react [face/font: syswin/font]
        fontlist: drop-list  data uifonts on-change [
                                    set-scheme colorlist/text face/text
                                    apply-scheme]
                                on-create [
                                    face/selected: 1
                                    face/text: pick face/data face/selected
                                ]
    ] react [face/color: syswin/color]
    do [attempt [livewin/pane: layout/only load syswin/text]]
]
View/options/flags layout Core [actors:
    object [
        on-key-down: func [face event][
            ; escape 27
            ; delete 8
            if event/key = 27 [askclose]
            if (⌘) [
                case [
                    event/key = #"Q" [unview quit]
                    event/key = #"N" [
                        ; WIP
                        ; askname "Create File" deffile
                    ]
                    event/key = 8 [
                        sel: treelist/selected
                        if (sel <> none) [
                            ; WIP
                            ; askyes "Remove File" sel
                        ]
                    ]
                    event/key = #"S" [autosave]
                    event/key = #"B" [
                        stop: stopexe
                        if stop [stopexe: false]
                        execute codemill
                        stopexe: stop
                    ]
                ]
            ]
            if (form event/key) = "left-command" [⌘: true]
            if (form event/key) = "left-shift" [leftshift: true]

        ]
        on-key-up: func [face event][
            if (form event/key) = "left-command" [⌘: false]
            if (form event/key) = "left-shift" [leftshift: false]
        ]
        on-click: func[face][
            if sysbut/selected [
                face/size: either sysclose [face/size + sysclose-wh
                                        ][face/size - sysclose-wh]
            ]
        ]
        on-close: func [face event][autosave]
    ]
][no-min]


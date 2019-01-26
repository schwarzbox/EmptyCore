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

; v0.3
; leftshift
; problem save when use new file

; scrool tab panel
; drag and drop

; filetree update delete copy save
; quit q sourcecode
; Red Header if?
; custom style sys button  🧩 ⚙️ 🎬 ⚠️ ▼ ⚗︎ ⚙ ⚒︎ ⚛︎

; make constants sizes
; user change codefnt

; scrool numbers refcator close button
; save editor state for all panels separate default and and user setup

; 0.4
; show errors in terminal
; theme rtf color for syntax native mezanine

; check quotes print prin view probe input ask!
; improve ask and input in loop change val

; update view problem (use modal window?)

; v0.5
; make modules draw
; save images

; v0.6

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
                        style: [regular] size: 18 color: sysclr]
]

apply-scheme: func []  [
    syswin/color: dispclr
    syswinfnt/color: sysclr
    syswin/font: syswinfnt
    sysbar/color: mainclr
    sysbarfnt/color: sysclr
    sysbut/font: sysbarfnt
    syspan/color: dispclr
    schemelab/font/color: sysclr
    schemefont/font/color: sysclr

    codemill/color: dispclr
    codenumbers/color: dispclr
    terminal/color: dispclr
    viewengine/color: dispclr
    drawmachine/color: dispclr
    iospace/color: dispclr

    codelabel/font: syswinfnt
    terminallabel/font: syswinfnt
    viewlabel/font: syswinfnt
    drawlabel/font: syswinfnt
    iolabel/font: syswinfnt
    iocol: iohidden/font/color
    iohidden/font: copy syswinfnt
    if iocol = gray [iohidden/font/color: iocol]

    codeclose/font/color: sysclr
    terminalclose/font/color: sysclr
    viewclose/font/color: sysclr
    drawclose/font/color: sysclr
    ioclose/font/color: sysclr

    codepan/color: mainclr
    terminalpan/color: mainclr
    viewpan/color: mainclr
    drawpan/color: mainclr
    iopan/color: mainclr

    codemill/font/color: codeclr
    terminal/font/color: codeclr

    foreach tab tabpan/pane [
        either tab/color = tabpan/color [
            tab/color: mainclr
        ][
            tab/color: dispclr
        ]
    ]
    tabpan/color: mainclr
]

set-scheme "Core" "Andale"
syswin-wh: 1154x256
sysbar-wh: as-pair (syswin-wh/x + 256) 23
sysbut-wh: 64x24
sysclose: 0x256
livewin-wh: as-pair (syswin-wh/x + 256) 512
close: true

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
        sysbut: button "⚛︎" sysbut-wh font sysbarfnt
                            on-click [close: not close
                            ] on-over [
                                face/selected: either event/away? [none][true]
                            ]
    ]

    return
    syswin: display code syswin-wh on-change [attempt [livewin/pane:
                                                layout/only load face/text]]

    syspan: panel 256x256 dispclr [
        origin 0x1 space 0x0
        schemelab: text "Scheme" font syswinfnt
        colorlist: drop-list  data uicolors on-change [
                                    set-scheme face/text fontlist/text
                                    apply-scheme]
                                on-create [
                                    face/selected: 1
                                    face/text: pick face/data face/selected
                                ]
        return
        schemefont: text "Font" font syswinfnt
        fontlist: drop-list  data uifonts on-change [
                                    set-scheme colorlist/text face/text
                                    apply-scheme]
                                on-create [
                                    face/selected: 1
                                    face/text: pick face/data face/selected
                                ]
    ]
    do [attempt [livewin/pane: layout/only load syswin/text]]
]
View/options/flags layout Core [actors:
    object [
        ; on-over: func [face] [face/color: mainclr]
        on-key-down: func [face event][
            ; escape
            ; if event/key = 27 [unview quit]
            if (⌘ and (event/key = #"Q")) [unview quit]
            if (form event/key) = "left-command" [⌘: true]
            if (form event/key) = "left-shift" [leftshift: true]

        ]
        on-key-up: func [face event][
            if (form event/key) = "left-command" [⌘: false]
            if (form event/key) = "left-shift" [leftshift: false]
        ]
        on-click: func[face][
            if sysbut/selected [
                face/size: either close [face/size + sysclose
                                        ][face/size - sysclose]
            ]
        ]
        ; on-close: func [face event][ alert ["🔴"]]
    ]
][no-max no-min]


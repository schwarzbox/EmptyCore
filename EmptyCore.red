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

; v0.2
; numbers
; update view problem (use modal window?)
; check quotes print prin view probe input ask!
; improve ask and input in loop
; change font theme rtf color for syntax

; show errors in terminal

; refactor

; change fonts or make panel
; close buttons for draw machine view engine

; find emoji for buttons  🧩⚙️ 🎬 ⚠️ ▼ ⚗︎ ⚙ ⚒︎ ⚛︎
; custom style buttons

; make modules draw file system(setting)
; drag and drop files to Code

; save editor state for all panels
; save script in var
; save image in var
; add auto save command and cmd-s cmd-shift-s cmd-o

system/view/auto-sync?: yes

; load editable sourcecode
do read %sourcecode.red
code: mold sourcecode

mainclr: tuple!
dispclr: tuple!
codeclr: tuple!
sysclr: tuple!

uitheme: block!
set-uicolor: func [theme] [
    uicolors: [ecode: [
            main: 32.32.32
            disp: 42.42.42
            code: 222.222.222
            system: 32.196.255
        ]
    ]
    uitheme: copy []
    foreach file read %. [
        if file = "uicolors.red" [do read %uicolors.red]
    ]

    foreach clr uicolors [
        if (type? clr) = set-word! [append uitheme form clr]
    ]

    mainclr: do rejoin["uicolors/" theme "/main"]
    dispclr: do rejoin["uicolors/" theme "/disp"]
    codeclr: do rejoin["uicolors/" theme "/code"]
    sysclr: do rejoin["uicolors/" theme  "/system"]
]

set-theme: func []  [
    syswin/color: dispclr
    syswinfont/color: sysclr
    syswin/font: syswinfont
    sysuifont/color: sysclr
    sysbut/font: sysuifont
    themelab/font/color: sysclr
    iolab/font/color: sysclr
    iowin/color: dispclr


    drawmachine/color: dispclr
    codemachine/color: dispclr
    codenumbers/color: dispclr
    terminal/color: dispclr
    viewengine/color: dispclr

    drawlabel/font: syswinfont
    codelabel/font: syswinfont
    terminallabel/font: syswinfont
    viewlabel/font: syswinfont

    codemachine/font/color: codeclr
    codenumbers/font/color: codeclr
    terminal/font/color: codeclr
]

set-uicolor "ecode"

syswin-wh: 1360x256
sysui-wh: as-pair (syswin-wh/x / 2) 23
sysclose: 0x256
livewin-wh: as-pair syswin-wh/x 512
close: true
txtsize: 10
labsize: 16

syswinfont: make font! [name: "Andale Mono"
                        style: [regular] size: txtsize color: sysclr]
sysuifont: make font! [name: "Helvetica"
                        style: [regular] size: labsize color: sysclr]

Core: [
    title "EmptyCore"
    backdrop mainclr
    origin 0x0 space 2x0
    style display: area dispclr wrap font syswinfont no-border

    below
    livewin: panel livewin-wh
    across
    panel sysui-wh [
        origin 0x1 space 0x0
        sysbut: button "⚛︎" 64x24 font sysuifont
                            on-click [close: not close
                            ] on-over [
                                face/selected: either event/away? [none][true]
                            ]
    ]

    panel sysui-wh [
        origin 0x1 space 0x0
        themelab: text "Color" right font-color sysclr
        drop-list  data uitheme on-change [set-uicolor face/text
                                                set-theme]
                                on-create [face/selected: 1]
        themefont: text "Font" right font-color sysclr
    ]
    return
    syswin: display code syswin-wh on-change [
                    attempt [livewin/pane: layout/only load face/text]
                ]


    do [attempt [livewin/pane: layout/only load syswin/text]]
]
View/options/flags layout Core [actors:
    object [
        cmd: false
        on-key-up: func [key event][
            if form event/key = "left-command" [cmd: false]
        ]
        on-key-down: func [key event][
            ; escape
            if event/key = 27 [unview quit]
            if cmd and (event/key = #"Q") [unview quit]
            if cmd and (event/key = #"S") [print "save"]
            if cmd and (event/key = #"O") [print "open"]
            if (form event/key = "left-command") [cmd: true]
        ]

        on-click: func[face][
            if sysbut/selected [
                face/size: either close [face/size + sysclose
                                        ][face/size - sysclose]
            ]
        ]
        on-over: func [face] [face/color: mainclr]
        ; on-close: func [face event][ alert ["🔴"]]
    ]
][no-max no-min]


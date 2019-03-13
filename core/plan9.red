#!/usr/bin/env red
Red [Needs: View]

View [
    origin 2x2 space 2x2
    below
    disp: panel 636x450 mainclr [

    ]
    across
    panel [
        origin 0x0 space 0x0
        inp: field {https://upload.wikimedia.org/wikipedia/commons/1/13/Wireworld_XOR-gate.gif} 596 white
            button "OK" 36x20 [
            img: load inp/text
            append disp/pane layout/only load "image 620x330 img  loose"
        ]
    ]
]

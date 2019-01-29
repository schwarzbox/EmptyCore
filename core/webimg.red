Red []

View [
    below
    disp: panel gray 490x370 [

    ]
    across
    panel [
        origin 0x0 space 0x0
        inp: field "https://avatars2.githubusercontent.com/u/31594850?s=400&u=ca76b78e64fb92cdfb04ba9da0309639b9022337&v=4" 450 white
        button "OK" 38x20 [
						img: load inp/text
						append disp/pane layout/only load "image img loose"
		]
    ]

]



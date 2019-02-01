#!/usr/bin/env red
Red [
	needs: 'View
]

View [
    below
    disp: panel mainclr 490x440 [

    ]
    across
    panel [
        origin 0x0 space 0x0
        inp: field {https://lh5.googleusercontent.com/proxy/vMZSKcv9Nn1rOflLPfkzSWQbE1NdQVYIM3fbim2lWScpDYCaw6oK8yzj33FkA70uUl5tECTQc492JFMnGMtyEtEmIv1Tv5GZq3zyewmMa-sH8U42yPhF9Zg89fyW6gAU0XXd39qEV2Uv2g=s0} 450 white
        button "OK" 36x20 [
						img: load inp/text
						append disp/pane layout/only load "image img loose"
		]
    ]

]
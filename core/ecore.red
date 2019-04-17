#!/usr/bin/env red
Red [needs: View]

View [
	origin 2x2 space 0x0
	panel [
		origin 256x128 space 0x0
		below
		t: text 128x32 "EmptyCore" center font-color white react [face/text: f/text]
		button 128x64 "⚛︎" font-size 32 [
			insert t/text rejoin [face/text " "]]
		text 128x32 "v0.38" center font-color white
		f: field 128 center "EmptyCore" on-change [t/text: face/text]
	]
]

# EmptyCore-Red

WIP

v0.35

"EmptyCore" - Experimental LiveCoding Environment

With "EmptyCore" you can see result of the executed code in a real-time.
You can stop it by pressing ∞ in the Console panel.
If you stop automatic execution you can see error in the Console.
To run code manually press cmd-b or ↺ in Console panel.

![Screenshot](screenshot/screenshot1.png)

You can see source code of the "EmptyCore" and change it on the fly. Be careful.

Parsing very simple and you can have some strange situation if use "view" "print", "prin", "probe" words as strings.

Function "ask" and "input" not yet implemented.

All variables stay defined until close "EmptyCore". If you define and after comment variable - nothing happen. Variable saved in the memmory.

![Screenshot](screenshot/screenshot2.png)

[Inspired by Red Programming Language](https://www.red-lang.org)

To run source code: clone repository, download & install [Red](https://www.red-lang.org/p/download.html) for you system and run command in shell:

``` bash
red EmptyCore.red
```

v0.35

- simple file tree

- code editor

- source code viewer/editor

- console output

- graphical output

- show errors in console

- hotkeys cmd-q quit cmd-s save cmd-b build esc close dialog

v0.4

- close button for file in code editor

- dialog cursor color

- arrow navigation in file tree

- tree focus problem

- custom file tree?

- resize panels?

- improve numbers

- save user setting for source code and run after main programm

- font panel

v0.5

- improve key word parsing "view" "print" "probe" "prin" "ask" "input"

- syntax color for editor

- problem with view reactor?

- show line error






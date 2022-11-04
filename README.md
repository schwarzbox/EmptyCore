# EmptyCore

v0.38

Experimental LiveCoding Environment

With "EmptyCore" you can see result of the executed code in a real-time.
You can stop it by pressing ∞ in the Code panel.
If you stop automatic execution you can see error in the console.
To run code manually press cmd-b or "Code" in Console panel.

Be careful when delete files with Tree remove dialog.

![Screenshot](screenshot/screenshot1.png)

You can see source code of the "EmptyCore" and change it on the fly. Be careful.

Function "ask" and "input" not yet implemented.

All variables stay defined until close "EmptyCore". If you define and after comment variable - nothing happen. Variable stay saved in the memory.

![Screenshot](screenshot/screenshot2.png)

[Inspired by Red Programming Language](https://www.red-lang.org)

To run source code: clone repository, download & install [Red](https://www.red-lang.org/p/download.html) for you system and run command in shell:

``` bash
red EmptyCore.red
```

v0.38

- simple file tree

- draw editor (pixel editor, .png, 192x192 px, colorpicker, grid, rotate, del, fill, undo & auto crop)

- code editor (console output, errors)

- source code (viewer/editor)

- View(VID output)

- hotkeys main cmd-q: quit

- hotkeys code cmd-n: new file cmd-s: save cmd-b: build

- hotkeys tree cmd-r: rename dialog cmd-backspace: remove dialog esc: close dialog

- themes and font panel

v0.4

- compile user projects for diferent systems

- save user setting for source code and run after main programm

-  image name

- close button for file in code editor

- tree focus problem

- custom file tree?

v0.5

- improve "ask" "input" "about" "help"

- syntax color for editor

- show line error

- improve numbers

- improve selected line





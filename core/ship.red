#!/usr/bin/env red
Red [Needs: View]

; refactor scale anchor offset fire
; mass
; add impulse
; stars
; split aster
; animation (fire engine with particles)

random/seed now
WH: 640x480
SCALE: 0.3
CANWID: WH/x / SCALE
CANHEI: WH/y / SCALE
MIDWID: CANWID / 2
MIDHEI: CANHEI / 2
FPS: 60
DT: 0.016
AST: 3

simg: load %ship.png
limg: load %laser.png
aimg: load %aster.png

asteroids: AST
objects: []
trash: []

proto: object [tag: "proto"  img: none size: none offset: 0x0
			x: 0 y: 0 vx: 0 vy: 0 ax: 0 ay: 0 speed: 0
			angle: 0 va: 0 aa: 0 torque:0 anchor: 0x0 sc: SCALE piv: none
			dead: false
			applyforce: func[fx fy] [
				ax: ax + fx
				ay: ay + fy
			]
			applytorque: func[tor] [
				aa: aa + tor
			]
			linearvelocity: does [
				vx: vx + (ax * DT)
				vy: vy + (ay * DT)
				x: (x + vx)
				y: (y + vy)
			]
			angularvelocity: does [
				va: va + (aa * DT)
				angle: angle + va
			]
			resetacceleration: does [
				ax: 0
				ay: 0
				aa: 0
			]
			lineardamp: does [
				vx: vx - (vx * DT)
				vy: vy - (vy * DT)
			]
			angulardamp: does [
				va: va - (va * DT)
			]
			collide: func [self coll] [

			]
			borders: does [
				if ((x + piv/x) < 0) [x: x + CANWID return true]
				if ((x + piv/x) > CANWID) [x: 0 return true]
				if ((y + piv/y) < 0) [y: y + CANHEI return true]
				if ((y + piv/y) > CANHEI) [y: 0 return true]
			]
			update: func [self] [
				linearvelocity
				angularvelocity
				resetacceleration
				anchor: ((as-pair x y) * sc) + piv
				offset: as-pair x y
			]

			draw: does [
				append world/draw compose/deep/only [
					transform (anchor) (angle) (sc) (sc) 0x0
					[image (img) (as-pair x y)]
				]
			]
		]

ship: make proto [tag: "ship" img: simg size: simg/size
				x: MIDWID - ((simg/size/x / 2))
				y: MIDHEI - ((simg/size/y / 2))
				speed: 64
				torque: 32
				piv: (simg/size / 2) * sc
				guns: 0x32
				cooldown: 2
			update: func [self] [
				linearvelocity
				angularvelocity
				lineardamp
				angulardamp
				resetacceleration
				borders
				anchor: ((as-pair x y) * sc) + piv
				offset: as-pair x y
			]
			fire: does [
				coslas: cosine ship/angle
				sinlas: sine ship/angle
				; direct
				szx: ship/size/x / 2
				szy: ship/size/y / 2

				midwid: coslas * (szx)
				midhei: sinlas * (szy)
				horx: coslas * (guns/x)
				hory: sinlas * (guns/x)
				verx: coslas * (guns/y * -1)
				very: sinlas * (guns/y * -1)

				dir1x: horx - very + (midwid) + (ship/x + (szx))
				dir1y: hory + verx + (midhei) + (ship/y + (szy))

				verx: coslas * (guns/y)
				very: sinlas * (guns/y)

				dir2x: horx - very + (midwid) + (ship/x + (szx))
				dir2y: hory + verx + (midhei) + (ship/y + (szy))

				either (cooldown = 2) [
					las1: make laser [x: dir1x - (laser/size/x / 2)
										y: dir1y - (laser/size/y / 2)
											angle: ship/angle]
					las1/applyforce (coslas * las1/speed) (sinlas * las1/speed)
					append objects copy las1
					cooldown: 1
				][
					las2: make laser [x: dir2x - (laser/size/x / 2)
									y: dir2y - (laser/size/y / 2)
										angle: ship/angle]
					las2/applyforce (coslas * las2/speed) (sinlas * las2/speed)
					append objects copy las2
					cooldown: 2

				]
			]
		]

laser: make proto [tag: "laser" img: limg size: limg/size speed: 2000
			piv: (limg/size / 2) * sc
			update: func [self] [
				linearvelocity
				angularvelocity
				resetacceleration
				border?: borders
				if (border?) [append trash self]
				anchor: ((as-pair x y) * sc) + piv
				offset: as-pair x y
			]
		]

aster: make proto [tag: "aster" img: aimg size: aimg/size
			speed: 4
			torgue: 2
			piv: (aimg/size / 2) * sc
			update: func [self] [
				linearvelocity
				angularvelocity
				resetacceleration
				borders
				anchor: ((as-pair x y) * sc) + piv
				offset: as-pair x y
			]
			collide: func [self coll] [
				over?: overlap? self coll
				if (over?) [
					if (coll/tag = "laser" and not dead) [
						dead: true
						asteroids: asteroids - 1
						append trash self
					]
				]
			]
		]

spawnaster: func [num] [
	loop num [
		append objects make aster [x: random CANWID y: random CANHEI
							vx: ((random 1.0) * 2 - 1) * aster/speed
							vy: ((random 1.0) * 2 - 1) * aster/speed
							va: ((random 1.0) * 2 - 1) * aster/speed]
	]
]

spawnaster asteroids

View [
	title "Asteroids"
	origin 0x0 space 0x0
	world: panel reblue WH draw [] [

	] rate FPS on-time [
		world/draw: copy [anti-alias off]
		ship/draw
		ship/update ship


		foreach obj objects [
			obj/draw
			obj/update obj

			foreach coll objects [
				obj/collide obj coll
			]
		]

		remove-each obj objects [find trash obj]
		trash: copy []
		if (asteroids <= 0) [
			AST: AST + 1
			asteroids: AST + 1
			spawnaster asteroids
		]
	] on-key-down [
		key: form (event/key)
		case/all [
			(key = "W") [
				ship/applyforce ((cosine ship/angle) * ship/speed) ((sine ship/angle) * ship/speed)
			]
			(key = "D") [
				ship/applytorque ship/torque
			]
			(key = "A") [
				ship/applytorque (ship/torque * -1)
			]
		]
		if (key = " ") [ ship/fire ]
	]

]








//           `--::-.`
//       ./shddddddddhs+.
//     :yddddddddddddddddy:
//   `sdddddddddddddddddddds`
//  /ddddy:oddddddddds:sddddd/   @By: Debray Arnaud <adebray> - adebray@student.42.fr
//  sdddddddddddddddddddddddds   @Last modified by: adebray
//  sdddddddddddddddddddddddds
//  :ddddddddddhyyddddddddddd:   @Created: 2017-06-17T18:17:57+02:00
//   odddddddd/`:-`sdddddddds    @Modified: 2017-06-17T18:57:18+02:00
//    +ddddddh`+dh +dddddddo
//     -sdddddh///sdddddds-
//       .+ydddddddddhs/.
//           .-::::-`

const fs = require("fs")

tables = {
	and: (a, b) => a & b,
	or: (a, b) => a | b,
	xor: (a, b) => a ^ b,
	imply: (a, b) => a == true && b == false ? 0 : 1,
	equivalent: (a, b) => a == b ? 1 : 0
}

lines = [
	[""],
	[""],
	[""],
	["1, 1 :"],
	["1, 0 :"],
	["0, 1 :"],
	["0, 0 :"],
]
let pileUp = (i, l) => {
	if (!lines[i])
		lines[i] = [l]
	else
		lines[i].push(l)
}

Object.keys(tables).forEach( k => {
	let v = tables[k]

	pileUp(0, "--------")
	pileUp(1, k)
	pileUp(2, "--------")
	pileUp(3, v(true, true) )
	pileUp(4, v(true, false) )
	pileUp(5, v(false, true) )
	pileUp(6, v(false, false) )
})

let padding = 12
lines.forEach(e => {
	e.forEach(e => {
		process.stdout.write(e.toString())
		for (var i = 0; i < padding - e.toString().length; i++) {
			process.stdout.write(" ")
		}
	})
	process.stdout.write("\n")
})

if (!process.argv[2])
	console.log("no input file")
else {
	fs.readFile(process.argv[2], (err, dt) => process.stdout.write(dt.toString()))
}

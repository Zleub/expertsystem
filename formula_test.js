//           `--::-.`
//       ./shddddddddhs+.
//     :yddddddddddddddddy:
//   `sdddddddddddddddddddds`
//  /ddddy:oddddddddds:sddddd/   @By: Debray Arnaud <adebray> - adebray@student.42.fr
//  sdddddddddddddddddddddddds   @Last modified by: adebray
//  sdddddddddddddddddddddddds
//  :ddddddddddhyyddddddddddd:   @Created: 2017-07-16T23:39:14+02:00
//   odddddddd/`:-`sdddddddds    @Modified: 2017-07-17T00:07:08+02:00
//    +ddddddh`+dh +dddddddo
//     -sdddddh///sdddddds-
//       .+ydddddddddhs/.
//           .-::::-`

let tables = require('./main.js')
let write = process.stdout.write

process.stdout.write(`o p n l | O + P => L + N | O + P => L | N | O + P => L ^ N \n`)
process.stdout.write(`------- | -------------- | -------------- | -------------- \n`)
for (var o = 0; o < 2; o++) {
	for (var p = 0; p < 2; p++) {
		for (var n = 0; n < 2; n++) {
			for (var l = 0; l < 2; l++) {
				let t = tables.imply( tables.and(o, p), tables.and(n, l))
				let t2 = tables.imply( tables.and(o, p), tables.or(n, l))
				let t3 = tables.imply( tables.and(o, p), tables.xor(n, l))
				process.stdout.write(`${o} ${p} ${n} ${l} |        ${t}       |        ${t2}       |        ${t3}       |\n`)
			}
		}
	}
}

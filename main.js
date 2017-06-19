//           `--::-.`
//       ./shddddddddhs+.
//     :yddddddddddddddddy:
//   `sdddddddddddddddddddds`
//  /ddddy:oddddddddds:sddddd/   @By: Debray Arnaud <adebray> - adebray@student.42.fr
//  sdddddddddddddddddddddddds   @Last modified by: adebray
//  sdddddddddddddddddddddddds
//  :ddddddddddhyyddddddddddd:   @Created: 2017-06-17T18:17:57+02:00
//   odddddddd/`:-`sdddddddds    @Modified: 2017-06-19T21:44:00+02:00
//    +ddddddh`+dh +dddddddo
//     -sdddddh///sdddddds-
//       .+ydddddddddhs/.
//           .-::::-`

const fs = require("fs")

colors = {
	reset: "\x1b[0m",
	bright: "\x1b[1m",
	dim: "\x1b[2m",
	underscore: "\x1b[4m",
	blink: "\x1b[5m",
	reverse: "\x1b[7m",
	hidden: "\x1b[8m",

	fgblack: "\x1b[30m",
	fgred: "\x1b[31m",
	fggreen: "\x1b[32m",
	fgyellow: "\x1b[33m",
	fgblue: "\x1b[34m",
	fgmagenta: "\x1b[35m",
	fgcyan: "\x1b[36m",
	fgwhite: "\x1b[37m",

	bgblack: "\x1b[40m",
	bgred: "\x1b[41m",
	bggreen: "\x1b[42m",
	bgyellow: "\x1b[43m",
	bgblue: "\x1b[44m",
	bgmagenta: "\x1b[45m",
	bgcyan: "\x1b[46m",
	bgwhite: "\x1b[47m",
}

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

let log = console.log

if (!process.argv[2])
	console.log("no input file")
else {
	fs.readFile(process.argv[2], (err, dt) => {
		let facts = {}
		let queries = []
		let rules = []

		let readLine = (dt) => {
			let s = dt.toString()
			if (s != "") {
				let r = s.match(/([^\n]+)\n/)
				if (r != null) {
					rules.push(r[1])
					readLine(s.substr(r[0].length))
				}
			}
		}
		readLine(dt)

		log(`${colors.fgred}Not parsed rules:${colors.reset}`)
		log(rules)

		rules = rules.map( e => {
			let r = e.match(/([^#]+)#/)
			if (e.indexOf("#") == -1)
				return e
			return (r == null) ? null : r[1].trim()
		}).filter( e => e != null)

		.map( e => {
			let r = e.match(/\w/g)
			if (r != null)
				r.forEach( e => facts[e] = false)

			return e
		})
		.map( e => {
			let r = e.match(/=(\w+)/)
			if (r)
				r[1].match(/\w/g).forEach( e => facts[e] = true)
			return e
		})
		.map( e => {
			let r = e.match(/\?(\w+)/)
			if (r)
				r[1].match(/\w/g).forEach( e => queries.push(e))
			return e
		})
		.map( e => {
			let r
			let i = e.indexOf("+")
			while ( i != -1 ) {
				r = {
					left: e.substr(0, i).trim(),
					right: e.substr(i + 1).trim()
				}
				i = r.right.indexOf("+")
				console.log(i)
			}
			return r
		} )
		// .map( e => {
		// 	let r = e.match(/(.+)<=>(.+)/)
		// 	return (r == null) ? e : tables.equivalent
		// })
		// .map( e => {
		// 	if (typeof e == "function")
		// 		return e
		// 	let r = e.match(/(.+)\+(.+)/)
		// 	return (r == null) ? e : tables.and
		// })
		// .map( e => {
		// 	if (typeof e == "function")
		// 		return e
		// 	let r = e.match(/(.+)=>(.+)/)
		// 	log("----")
		// 	log(r)
		// 	return (r == null) ? e : (facts) =>
		// })

		log(`${colors.fggreen}Post parsed rules:${colors.reset}`)
		rules.forEach( e => console.log(JSON.stringify(e, null, "  ")) )
		log(facts)
		log(queries)
	})
}

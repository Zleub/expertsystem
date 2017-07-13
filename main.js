//           `--::-.`
//       ./shddddddddhs+.
//     :yddddddddddddddddy:
//   `sdddddddddddddddddddds`
//  /ddddy:oddddddddds:sddddd/   @By: Debray Arnaud <adebray> - adebray@student.42.fr
//  sdddddddddddddddddddddddds   @Last modified by: adebray
//  sdddddddddddddddddddddddds
//  :ddddddddddhyyddddddddddd:   @Created: 2017-06-17T18:17:57+02:00
//   odddddddd/`:-`sdddddddds    @Modified: 2017-07-14T01:32:24+02:00
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

let log = console.log
let prettylog = e => console.log(JSON.stringify(e, null, "  "))

let ops = [
	"<=>",
	"=>",
	"^",
	"|",
	"+"
]

let split_operator = (e) => {
	console.log(e)
	console.log(e instanceof Array)
	for (var i = 0; i < ops.length; i++) {
		let op = ops[i]
		let j = e.indexOf(op)

		if ( j != -1 ) {
			return {
				type: op,
				left: split_operator(e.substr(0, j).trim()),
				right: split_operator(e.substr(j + op.length).trim())
			}
		}
	}
	return e
}

let test = e => {
	let m = e.match(/\((.+)\)/)
	if (m) {
		return [].concat.apply([], [e.replace(`(${m[1]})`, "ANO"), test(m[1])])
	}
	return e
}

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

		log(`Not parsed rules`)
		let ref_rules = rules.map(e => e)
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
		.map(test)
		// rules.

		rules = rules.map( e => split_operator(e) )

		log(`Post parsed rules`)
		rules.forEach(prettylog)
		log("facts: ", facts)
		log("queries: ", queries)
	})
}

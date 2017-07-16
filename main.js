//           `--::-.`
//       ./shddddddddhs+.
//     :yddddddddddddddddy:
//   `sdddddddddddddddddddds`
//  /ddddy:oddddddddds:sddddd/   @By: Debray Arnaud <adebray> - adebray@student.42.fr
//  sdddddddddddddddddddddddds   @Last modified by: adebray
//  sdddddddddddddddddddddddds
//  :ddddddddddhyyddddddddddd:   @Created: 2017-06-17T18:17:57+02:00
//   odddddddd/`:-`sdddddddds    @Modified: 2017-07-17T01:13:34+02:00
//    +ddddddh`+dh +dddddddo
//     -sdddddh///sdddddds-
//       .+ydddddddddhs/.
//           .-::::-`

const colors = require('colors')
const fs = require("fs")

class Rule {
	constructor(type, left, right) {
		this.type = type
		this.left = left
		this.right = right
	}

	contains(q) {
		let b = false
		if (this.right instanceof Rule)
			b = b || this.right.contains(q)
		else
			b = b || (this.right == q)
		if (this.left instanceof Rule)
			b = b || this.left.contains(q)
		else
			b = b || (this.left == q)
		return b
	}

	do(rules, facts, queries) {
		if (!(this.left instanceof Rule) && !(this.right instanceof Rule)) {
			log('!(this.left instanceof Rule) && !(this.right instanceof Rule)')
			let a = solve(rules, facts, queries.concat([this.left]))
			let b = solve(rules, facts, queries.concat([this.right]))
			return tables[this.type](a, b)
		}
		if ((this.left instanceof Rule) && (this.right instanceof Rule)) {
			log('(this.left instanceof Rule) && (this.right instanceof Rule)')
			let a = this.left.solve(rules, facts, queries)
			let b = this.right.solve(rules, facts, queries)
			return tables[this.type](a, b)
		}
		else if (this.left instanceof Rule) {
			log('this.left instanceof Rule')
		}
		else if (this.right instanceof Rule) {
			log('this.right instanceof Rule')

		}
	}

	solve(rules, facts, queries) {
		let q = queries[queries.length - 1]
		if (this.contains(q))
		{
			if (this.right == q) {
				if (this.left instanceof Rule) {
					log('this.left instanceof Rule')
					return this.left.do(rules.filter( e => e != this), facts, queries)
				}
				else {
					log('!this.left instanceof Rule')
					return solve(rules.filter( e => e != this), facts, queries.concat([this.left]))
				}
			}
			else if (this.left instanceof Rule) {
				log('this.left instanceof Rule')
				return this.left.do(rules.filter(e => e != this), facts, queries)
			}
			else if (this.right instanceof Rule) {
				log('!this.right instanceof Rule')
				let b = this.right.do(rules.filter( e => e != this), facts, queries)
				log(this, b)
				return b
			}
		}
	}
}

let solve = (rules, facts, queries) => {
	let query = queries[ queries.length - 1]
	console.log(`search: ${query}`.cyan)
	let res = rules.reduce( (p, e) => {
		if (!p) {
			console.log(e)
			return e.solve(rules, facts, queries)
		}
		else
			return p
	}, undefined )
	if (res == true)
		console.log(`${query} true`)
	if (res == false)
		 console.log(`${query} false`)
	if (res == undefined) {
		console.log(`${query} undefined ${facts[query]}`)
		return facts[query]
	}
	return res
}

let opt = {
	'--debug': 'Toggle debugging.'
}
let _usage = Object.keys(opt).reduce( (p, k) => {
	p[k] = opt[k]
	return p
}, {})

process.argv.forEach((e, i) => {
	if (e == '--debug') {
		opt['--debug'] = true
		process.argv.splice(i, 1)
	}
})

let usage = () => {
	console.log('Expertsystem usage: ./expertsystem [...] file')
	Object.keys(_usage).forEach( k => {
		console.log(`\t${k}: ${_usage[k]}`)
	})
}

tables = {
	and: (a, b) => a & b,
	or: (a, b) => a | b,
	xor: (a, b) => a ^ b,
	imply: (a, b) => a == true && b == false ? 0 : 1,
	equivalent: (a, b) => a == b ? 1 : 0
}

tables["+"] = tables.and
tables["|"] = tables.or
tables["^"] = tables.xor
tables["=>"] = tables.imply
tables["<=>"] = tables.equivalent

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
if (opt['--debug'] == true) {
	lines.forEach(e => {
		e.forEach(e => {
			process.stdout.write(e.toString())
			for (var i = 0; i < padding - e.toString().length; i++) {
				process.stdout.write(" ")
			}
		})
		process.stdout.write("\n")
	})
}

let log = (...args) => {
	if (opt['--debug'] == true)
		console.log.apply(null, args)
}
let prettylog = e => console.log(JSON.stringify(e, null, "  "))

let ops = [
	"<=>",
	"=>",
	"^",
	"|",
	"+"
]

let split_operator = (e) => {
	let f = (e, index, array) => {
		let s = (array && e instanceof Array ? array[index] : e)
		for (var i = 0; i < ops.length; i++) {
			let op = ops[i]
			let j = s.indexOf(op)

			if ( j != -1 ) {
				let left = f(s.substr(0, j).trim(), index, array)
				let right = f(s.substr(j + op.length).trim(), index, array)
				left = (left == 'ANO' ? f(array, index + 1, array) : left)
				right = (right == 'ANO' ? f(array, index + 1, array) : right)
				return new Rule( op, left, right )
			}
		}
		return e
	}

	let res = f(e, 0, e instanceof Array ? e : undefined)
	if (res)
		return res
	return e
}

let parenthesis = e => {
	let m = e.match(/\((.+)\)/)
	if (m) {
		return [].concat.apply([], [e.replace(`(${m[1]})`, "ANO"), parenthesis(m[1])])
	}
	return e
}

let file = process.argv[process.argv.length - 1]
if (!file)
	console.log("no input file")
else {
	fs.readFile(file, (err, dt) => {
		let facts = {}
		let queries = []
		let rules = []

		let readLine = (dt) => {
			let s = dt
			let i = s.indexOf('\n')
			if (s != "" && i != -1) {
				rules.push(s.substr(0, i))
				readLine(s.substr(i + 1))
			}
		}
		if (err) {
			log(err.toString().red)
			usage()
			process.exit(0)
		}

		readLine(dt.toString())

		if (opt['--debug'] == true) {
			log(`Not parsed rules`)
			log(rules)
		}

		rules = rules.map( e => {
			if (e.indexOf("#") == -1)
				return e.trim()
			let r = e.match(/([^#]*)#/)
			return (r == null) ? null : r[1].trim()
		})
		.filter( e => e != null)
		.filter( e => e != "")

		.map( e => {
			let r = e.match(/\w/g)
			if (r != null)
				r.forEach( e => facts[e] = false)
			return e
		})
		.map( e => {
			let r = e.match(/=(\w*)$/)
			if (r) {
				if (r[1]) {
					r[1].match(/\w/g).forEach( e => facts[e] = true)
				}
				return null
			}
			return e
		})
		.filter( e => e != null)
		.map( e => {
			let r = e.match(/\?(\w+)/)
			if (r) {
				r[1].match(/\w/g).forEach( e => queries.push(e))
				return null
			}
			return e
		})
		.filter( e => e != null)
		.map(parenthesis)
		.map( e => split_operator(e) )

		if (opt['--debug'] == true) {
			log(`Post parsed rules`.magenta)
			rules.forEach( e => log(e))
			log("facts: ", facts)
			log("queries: ", queries)
		}

		console.log( queries.reduce( (p, q) => {
			console.log('---- ---- ---- ---- ---- ----')
			p[q] = solve(rules, facts, [q])
			return p
		}, {}) )
	})
}

module.exports = tables

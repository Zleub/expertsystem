--          `--::-.`
--      ./shddddddddhs+.
--    :yddddddddddddddddy:
--  `sdddddddddddddddddddds`
--  ydddh+sdddddddddy+ydddds  main.lua
-- /ddddy:oddddddddds:sddddd/ By adebray - adebray
-- sdddddddddddddddddddddddds
-- sdddddddddddddddddddddddds Created: 2015-08-20 00:37:49
-- :ddddddddddhyyddddddddddd: Modified: 2015-08-21 01:05:34
--  odddddddd/`:-`sdddddddds
--   +ddddddh`+dh +dddddddo
--    -sdddddh///sdddddds-
--      .+ydddddddddhs/.
--          .-::::-`

solve = require 'solver'
inspect = require 'inspect'

function debug(...) print(inspect(...)) end

local operators = {
	"!",
	"%+",
	"|",
	"%^",
	"=>",
	"<=>"
}

function getTree(line)
	print(line)
	if line:match('%(.+%)') then getTree(line:match('%((.+)%)')) end

	local tree = {}
	for i,v in ipairs(operators) do
		local l, o, r = line:match('(.+)('..v..')(.+)')
		if o then table.insert(tree, { operator = o, left = getTree(l), right = getTree(r) }) end
	end
end

if not arg[1] then
	print('Provide file plz')
else

	for l in io.lines(arg[1]) do
		debug( getTree(l) )
	end

	solve({
		operator = "=>",
		left = 'A',
		right = 'B'
	}, {'A', 'B'}, {['A'] = true})
end

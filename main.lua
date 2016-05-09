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

-- local operators = {
-- 	{ name = "!", match = "!" },
-- 	{ name = "+", match = "%+" },
-- 	{ name = "|", match = "|" },
-- 	{ name = "^", match = "%^" },
-- 	{ name = "=>", match = "=>" },
-- 	{ name = "<=>", match = "<=>" }
-- }

local operators = {
	{ name = "<=>", match = "<=>" },
	{ name = "=>", match = "=>" },
	{ name = "^", match = "%^" },
	{ name = "|", match = "|" },
	{ name = "+", match = "%+" },
	{ name = "!", match = "!" }
}

function get_index(elem)
	for i,v in ipairs(operators) do
		if v.name == elem then return i end
	end
end

function trim(str)
	return str:match('^%s*([^%s]*)%s*$')
end

function insert(t, variable)
	for i,v in ipairs(t) do
		if v == variable then return end
	end

	table.insert(t, variable)
end

function getTree(line, variables)
	if trim(line) then insert(variables, trim(line)) end
	if line:match('%(.+%)') then getTree(line:match('%((.+)%)'), variables) end

	for i,v in ipairs(operators) do
		local l, o, r, e

		if v.match == '!' then l, o, e, r = line:match('(.+)('..v.match..')(%S+)(.+)')
		else l, o, r = line:match('(.+)('..v.match..')(.+)') end

		if o then
			local left, right

			if l then
				left = getTree(l, variables)

			end
			if r then
				right = getTree(r, variables)

			end

			if left and right then
				local right_p = get_index(right.operator)
				local left_p = get_index(left.operator)
				local self_p = get_index(o)

				if right_p > self_p and right_p > left_p then
					right.left = { operator = o, left = e or nil } -- left = l, right = r }
					left.right = right
					return left
				elseif left_p > self_p and right_p < left_p then
					left.right = { operator = o, left = e or nil } -- left = l, right = r }
					right.left = left
					return right
				end
			end

			return { operator = o, left = getTree(l, variables) or trim(l), right = getTree(r, variables) or trim(r) }
			-- table.insert(tree, { operator = o, left = getTree(l), right = getTree(r) })
		end
	end
end

if not arg[1] then
	print('Provide file plz')
else

	local c, q
	local trees, variables = {}, {}
	for l in io.lines(arg[1]) do
		local constrains = l:match('^%s*=(%S*)%s*$')
		local query = l:match('^%s*%?(%S*)%s*$')

		if l ~= '' and not query and not constrains then
			local tree = getTree(l, variables)
			if tree then table.insert(trees, tree) end
		elseif l ~= '' and constrains then
			c = constrains
		elseif l ~= '' and query then
			q = query
		end
	end

	q_table = {}
	for v in q:gmatch('([^%s])') do
		q_table[v] = true
	end

	debug(trees)
	debug(variables)

	-- solve(trees[1], variables, q_table)
end

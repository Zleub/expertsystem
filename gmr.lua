function get_precedence(str)
	local precedence_ordered = {
		'comment', 'if_only_if', 'implies'
	}

	local make_precedence = function (operator, str)
		if not str then return end

		local a, b = str:find(operator)
		if not a or not b then return end

		local h, t = str:sub(1, a - 1), str:sub(a + #operator, #str)
		return h, operator, t
	end

	local precedence = {
		comment = function (str)
			local a, b = str:find('#')
			if not a or not b then return end

			local h, t = str:sub(1, a - 1), str:sub(a, #str)
			return h
		end,
		if_only_if = function (str)
			return make_precedence('<=>', str)
		end,
		parenthesis = function () end,
		implies = function (str)
			return make_precedence('=>', str)
		end
	}

	local s = str
	print('---------------------------')
	for i,v in ipairs(precedence_ordered) do
		local o, t

		s, o, t = precedence[v](s)
		print(o,  string.format("%- 20s, %- 20s, %- 20s", v, s, t) )
	end
end

function do_file(self, filename)

	local file = io.open(filename)
	if not file then
		print('Provide VALID file plz')
		return
	end

	for line in file:lines() do
		-- print(line)
		get_precedence(line)
	end


end

return setmetatable({}, { __call = do_file })

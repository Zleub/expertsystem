	--          `--::-.`
--      ./shddddddddhs+.
--    :yddddddddddddddddy:
--  `sdddddddddddddddddddds`
--  ydddh+sdddddddddy+ydddds  gmr.lua
-- /ddddy:oddddddddds:sddddd/ By adebray - adebray
-- sdddddddddddddddddddddddds
-- sdddddddddddddddddddddddds Created: 2015-08-20 01:17:11
-- :ddddddddddhyyddddddddddd: Modified: 2015-08-24 00:59:28
--  odddddddd/`:-`sdddddddds
--   +ddddddh`+dh +dddddddo
--    -sdddddh///sdddddds-
--      .+ydddddddddhs/.
--          .-::::-`

-- {
-- 	'MAIN' = {
-- 		{
-- 			type == 'rule' | 'operator' | 'terminal',
-- 			content == string
-- 		},
-- 		{
-- 			type == 'rule' | 'operator' | 'terminal',
-- 			content == string
-- 		},
-- 		...
-- 	}
-- 	'FACTS' = {
-- 		{
-- 			type == 'rule' | 'operator' | 'terminal',
-- 			content == string
-- 		},
-- 		{
-- 			type == 'rule' | 'operator' | 'terminal',
-- 			content == string
-- 		},
-- 		...
-- 	}
-- }

local gmr = {}

function prepare_match(v)
	v:gsub("%(", "%%(")
	v:gsub("%)", "%%)")
	v:gsub("%.", "%%.")
	v:gsub("%%", "%%%")
	v:gsub("%+", "%%+")
	v:gsub("%-", "%%-")
	v:gsub("%*", "%%*")
	v:gsub("%?", "%%?")
	v:gsub("%[", "%%[")
	v:gsub("%^", "%%^")
	v:gsub("%$", "%%$")
	v:gsub("%=", "%%=")

	return v
end

function gmr:open(gmrFile)
	self.file = io.open(gmrFile)
	if not self.file then
		print('Provide VALID gmr file plz')
	end
	return self
end

function gmr:levelup(bool)
	-- print('levelup', bool)
	self.level = self.level + 1
	return bool
end

function gmr:leveldown(bool)
	-- print('leveldown', bool)
	self.level = self.level - 1
	return bool
end

gmr.count = 0

function gmr:prepare_content(line)
	local rule = {}
	rule.name, rule.content = line:match('(%u+)%s*:=%s*(.+)')

	if rule.name then
		local t = {}
		-- local count = 1
		for match in rule.content:gmatch('(%S+)%s?') do
			table.insert(t, match)
		end
		rule.content = t

		self.level = 0
		self.line = 'caca'
		self.rules[rule.name] = rule.content
	end
end

function gmr:addrule(line)
	for content,control in line:gmatch('%[([%a%s%|]+)%]([%?%+%*]?)') do
		if content then
			self.count = self.count + 1
			self.rules['ANONYME'..self.count] = content
			local A, B
			content = prepare_match(content)
			if control ~= '' then
				A, B = line:find('%['..content..'%](['..control..']?)')
			else
				A, B = line:find('%['..content..'%]')
			end
			line = line:sub(1, A - 1)..'ANONYME'..self.count..control..line:sub(B + 1, #line)
			local t = {}
			-- local count = 1
			for match in content:gmatch('(%S+)%s?') do
				table.insert(t, match)
			end
			self.rules['ANONYME'..self.count] = t
		end
	end

	self:prepare_content(line)
end

function gmr:parse()
	if not self.file then
		print('No file')
	end

	self.rules = {}

	for line in self.file:lines() do
		self:addrule(line)
	end

	debug(self)
	return self
end

function gmr:call(rule)
	local option_flag, repeat_flag = false, false

	for i,value in ipairs(rule) do
		print(inspect(rule), self.line)

		local r, control = value:match('^([%u%d]+)([%+%?]?)$')

		if rule[i + 1] == '|' or control == '?' then
			option_flag = true
		end
		if control == '+' then
			repeat_flag = true
		end

		if r then
			-- print(value..' is a rule')
			local bool = self:call(self.rules[r])
			-- print('bool', bool, 'option_flag', option_flag)
			if repeat_flag and bool then
				while bool == true do
					bool = self:call(self.rules[r])
					print(bool)
					if self.line:find('^#.+') then
						print("testA")
						return false
					end
				end
				print("testB")
				return false
			end

			print("testC")

			if not option_flag and not bool then return bool
			elseif option_flag and bool then return bool end
		elseif value == '|' then
			-- pass next
		else
			if value:find("'") then
				value = value:sub(2, #value - 1)
			end
			value = prepare_match(value)
			-- print('MATCHER', value, self.line)
			if self.line:find('^'..value) then
				local A, B = self.line:find('^'..value..'%s*')
				-- print('sub', A,B)
				self.line = self.line:sub(B + 1, #self.line)
				-- print(self.line)
				return true
			end
		end

		if self.line:find('^#.+') then
			return true
		end
	end
end

function gmr:resolve(line)
	self.line = line
	local bool = self:call(self.rules['MAIN'])
	return bool
end

return gmr

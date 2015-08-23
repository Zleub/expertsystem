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

function gmr:addrule(line)
	local rule = {}

	rule.name, rule.content = line:match('(%u+)%s*:=%s*(.+)')

	if rule.name then
		local t = {}
		local count = 1
		for match in rule.content:gmatch('(%S+)%s?') do
			table.insert(t, match)
		end
		rule.content = t

		self.level = 0
		self.line = 'caca'
		self.rules[rule.name] = function (line)
			self.line = line
			self:levelup(self.level)

			local normaled = string.char(27)..'[0m'
			local underlined = string.char(27)..'[4m'
			local greyed = string.char(27)..'[100m'
			local leveled = string.char(27)..'[3'..self.level..'m'


			print("call: "..underlined.. rule.name..normaled, greyed..line..normaled)

			local i = 1
			while i ~= #rule.content + 1 do
				local v = rule.content[i]

				local m, c = v:match('^([A-Z]+)([%?%+%*]?)$') -- relaunch rule
				local g = v:match('^%[([A-Z]+)$') -- match rule grouping begin
				local e, gc = v:match('^([A-Z]+)%]([%?%+%*]?)$') -- match rule grouping end

				if self.line == '' then return self:leveldown('') end

				if m then
					print(leveled.."m_"..m..c..normaled)
					local res = self.rules[m](self.line)

					if res and rule.content[i + 1] == "|" then return self:leveldown(res) end
					if res then
						self.line = res
						line = res
					end

				elseif g then
					print(leveled.."g_"..v..normaled)
					local res = self.rules[g](self.line)

					if res and rule.content[i + 1] == "|" then return self:leveldown(res) end
					if res then
						self.line = res
						line = res
					end

				elseif e then
					print(leveled.."e_"..e.." -- "..gc..normaled)
					local res = self.rules[e](self.line)

					if res and rule.content[i + 1] == "|" then return self:leveldown(false) end
					if res then self.line = res
						line = res

						for j=i, 1, -1 do
							if rule.content[j]:match('^%[([A-Z]+)$') then
								i = j - 1
							end
						end
					end
				elseif v == "|" then
					;
				else
					if v:find("'") then
						v = prepare_match(v)
						v = v:sub(2, #v - 1)
					end

					print(leveled.."v_"..v..normaled)

					if line:match('^'..v) then
						if line:sub(1, 1) == '#' then
							return self:leveldown('')
						else
							line = line:match('^'..v..'%s*(.+)')
							return self:leveldown(line)
						end
					else
						if not (rule.content[i + 1] == "|" or c == '?') then
							return self:leveldown(false)
						end
					end
				end

				i = i + 1
			end

			if line == '' or line:sub(1, 1) == '#' then
				return self:leveldown('')
			end
			return self:leveldown(false)
		end
	end
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

function gmr:resolve(line)
	local bool = self.rules['MAIN'](line)
	debug(self)
	return bool
end

return gmr

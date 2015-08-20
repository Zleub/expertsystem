	--          `--::-.`
--      ./shddddddddhs+.
--    :yddddddddddddddddy:
--  `sdddddddddddddddddddds`
--  ydddh+sdddddddddy+ydddds  gmr.lua
-- /ddddy:oddddddddds:sddddd/ By adebray - adebray
-- sdddddddddddddddddddddddds
-- sdddddddddddddddddddddddds Created: 2015-08-20 01:17:11
-- :ddddddddddhyyddddddddddd: Modified: 2015-08-20 09:49:03
--  odddddddd/`:-`sdddddddds
--   +ddddddh`+dh +dddddddo
--    -sdddddh///sdddddds-
--      .+ydddddddddhs/.
--          .-::::-`

local gmr = {}

function gmr:open(gmrFile)
	self.file = io.open(gmrFile)
	if not self.file then
		print('Provide VALID gmr file plz')
	end
	return self
end

function gmr:levelup(bool)
	print('levelup', bool)
	self.level = self.level + 1
	return bool
end

function gmr:leveldown(bool)
	print('leveldown', bool)
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
		self.rules[rule.name] = function (line)
			self:levelup(self.level)

			local normaled = string.char(27)..'[0m'
			local underlined = string.char(27)..'[4m'
			local greyed = string.char(27)..'[100m'
			local leveled = string.char(27)..'[3'..self.level..'m'


			print("call: "..underlined.. rule.name..normaled, greyed..line..normaled)
			debug(rule.content, line)
			for i,v in ipairs(rule.content) do
				print('-- '..v)
				local m, c = v:match('^([A-Z]+)([%?%+%*]?)$') -- relaunch rule
				local g = v:match('^%[([A-Z]+)$') -- match rule grouping begin
				local e, gc = v:match('^([A-Z]+)%]([%?%+%*]?)$') -- match rule grouping end


				if m then
					print(leveled.."m_"..m..c..normaled)
					local res = self.rules[m](line)

					if not res and rule.content[i + 1] == "|" then -- next
					elseif not res then return self:leveldown(false) end
					if res and rule.content[i + 1] == "|" then return self:leveldown(res) end
					if res then line = res end
				elseif g then
					print(leveled.."g_"..v..normaled)
					local res = self.rules[g](line)

					if not res and rule.content[i + 1] == "|" then -- next
					elseif not res then return self:leveldown(false) end
					if res and rule.content[i + 1] == "|" then return self:leveldown(res) end
					if res then line = res end

				elseif e then
					print(leveled.."e_"..v..normaled)
					local res = self.rules[e](line)

					if not res and rule.content[i + 1] == "|" then -- next
					elseif not res then return self:leveldown(false) end
					if res and rule.content[i + 1] == "|" then return self:leveldown(res) end
					if res then line = res end
				elseif v == "|" then
					;
				else
					print(leveled.."v_"..v..normaled)
					if line:match('^'..v) then
						line = line:match('^'..v..'%s*(.+)')
						return self:leveldown(line)
					else
						return self:leveldown(false)
					end
				end


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
	self.rules['MAIN'](line)
end

return gmr
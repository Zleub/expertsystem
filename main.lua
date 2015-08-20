--          `--::-.`
--      ./shddddddddhs+.
--    :yddddddddddddddddy:
--  `sdddddddddddddddddddds`
--  ydddh+sdddddddddy+ydddds  main.lua
-- /ddddy:oddddddddds:sddddd/ By adebray - adebray
-- sdddddddddddddddddddddddds
-- sdddddddddddddddddddddddds Created: 2015-08-20 00:37:49
-- :ddddddddddhyyddddddddddd: Modified: 2015-08-20 01:46:14
--  odddddddd/`:-`sdddddddds
--   +ddddddh`+dh +dddddddo
--    -sdddddh///sdddddds-
--      .+ydddddddddhs/.
--          .-::::-`

inspect = require 'inspect'

function debug(...) print(inspect({...})) end

if not arg[1] then
	print('Provide file plz')
else
	local gmr = require('gmr'):open('gmr'):parse()
	local file = io.open(arg[1])
	if not file then
		print('Provide VALID file plz')
		return
	end

	for line in file:lines() do
		gmr:resolve(line)
	end
end


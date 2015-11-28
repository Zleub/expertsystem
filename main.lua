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

gmr = require 'gmr'
inspect = require 'inspect'

function debug(...) print(inspect({...})) end

if not arg[1] then
	print('Provide file plz')
else
	tree = gmr(arg[1])
	dofile('solver.lua')
end

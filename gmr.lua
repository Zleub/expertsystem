function do_file(self, filename)

	local file = io.open(filename)
	if not file then
		print('Provide VALID file plz')
		return
	end

	for line in file:lines() do
	   print(line)
	end

end

local obj = {}

setmetatable(obj, { __call = do_file })

return obj

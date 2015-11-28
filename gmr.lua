return function (filename)
	
	local file = io.open(filename)
	if not file then
		print('Provide VALID file plz')
		return
	end

	for line in file:lines() do
		-- scrap_comment
	end

	return {
		operator = "+",
		left = {
			operator = "|",
			left = {
				operator = "+",
				left = {
					operator = "|",
					left = "A",
					right = "B"
				},
				right = {
					operator = "+",
					left = "A",
					right = "C"
				}
			},
			right = "D"
		},
		right = "C"
	}

end
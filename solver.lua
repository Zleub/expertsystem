
local conditions = {};

conditions[1] = {
	content = "=>",
	left = "A",
	right = "C"
}
conditions[2] = {
	content = "=>",
	left = {
		content = "+",
		left = "A",
		right = "B"
	},
	right = "D"
}

local variables = { "A", "B", "C", "D" }

local constrains = {
	A = true,
	B = false,
}

local values = {}

function checkValues()
	for key, value in pairs(constrains) do
		if (values[key] ~= value) then
			return false
		end
	end

	return true
end

function debug()
	for i, value in ipairs(variables) do
		print(value, values[value])
	end
end

function testStep(index)
	if index == nil then
		return false
	elseif type(index) == "string" then
		return values[index]
	end

	local condition = conditions[index]
	local content = condition.content;
	local left = testStep(condition.left)
	local right = testStep(condition.right)

	if content == "+" then
		return left and right
	elseif content == "|" then
		return left or right
	elseif content == "!" then
		return not left
	elseif content == "^" then
		return not left == right
	elseif content == "=>" then
		return not left or right
	elseif content == "<=>" then
		return left == right
	elseif content >= "A" and content <= "Z" then
		return values[content]
	else
		return false
	end
end

function testProgram()
	for index, condition in ipairs(conditions) do
		if testStep(index) == false then
			return false
		end
	end
	return true
end

function test(index)
	if index == 0 then
		return testProgram()
	end

	local char = variables[index]

	if constrains[char] ~= nil then
		values[char] = constrains[char]
		if test(index - 1) == true then
			return true
		end
	else
		values[char] = false
		if test(index - 1) == true then
			return true
		end

		values[char] = true
		if test(index - 1) == true then
			return true
		end
	end

	return false
end

print("\nTesting...")

local result = test(#variables)

print("\nResult:", result, "\n")

if result then
	debug()
end

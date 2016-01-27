-- (P & Q) -> R <-> P -> (Q->R)
--
-- local tree = {
-- 	operator = "<=>",
-- 	left = {
-- 		operator = "=>",
-- 		left = {
-- 			operator = "+",
-- 			left = "P",
-- 			right = "Q"
-- 		},
-- 		right = "R"
-- 	},
-- 	right = {
-- 		operator = "=>",
-- 		left = "P",
-- 		right = {
-- 			operator = "=>",
-- 			left = "Q",
-- 			right = "R"
-- 		}
-- 	}
-- }
-- local variables = { "P", "Q", "R" }


-- ((A v B) & (A & C) v D ) & (C)

local tree = {
	operator = "=>",
	left = 'A',
	right = 'B'
}

-- local tree = {
-- 	operator = "+",
-- 	left = {
-- 		operator = "|",
-- 		left = {
-- 			operator = "+",
-- 			left = {
-- 				operator = "|",
-- 				left = "A",
-- 				right = "B"
-- 			},
-- 			right = {
-- 				operator = "+",
-- 				left = "A",
-- 				right = "C"
-- 			}
-- 		},
-- 		right = "D"
-- 	},
-- 	right = "C"
-- }

local variables = { "A", "B" }

local constrains = {}
local values = {}
local solutions = {}

for i, value in ipairs(variables) do
	values[value] = false
end

function debug(values)
	print("\t--------------")
	for i, value in ipairs(variables) do
		print("\t  ".. value, values[value])
	end
	print("\t--------------")
end

function addSolution()
	local index = #solutions + 1

	solutions[index] = {}

	for i, value in ipairs(variables) do
		solutions[index][value] = values[value]
	end
end

function testValues(operator, left, right)
	if operator == "+" then
		return left and right
	elseif operator == "|" then
		return left or right
	elseif operator == "!" then
		return not left
	elseif operator == "^" then
		return not left == right
	elseif operator == "=>" then
		return not left or right
	elseif operator == "<=>" then
		return left == right
	end

	return false
end

function test(tree)
	local left = tree.left
	local right = tree.right

	if type(left) == "table" then
		left = test(left)
	elseif type(left) == "string" then
		left = values[left]
	end

	if type(right) == "table" then
		right = test(right)
	elseif type(right) == "string" then
		right = values[right]
	end

	return testValues(tree.operator, left, right)
end

function solve(index)
	if index == nil then
		solve(#variables)
		return false
	end

	if index == 0 then
		if test(tree) then
			addSolution();
		end
		return false
	end

	local char = variables[index]

	if constrains[char] ~= nil then
		values[char] = constrains[char]
		if solve(index - 1) == true then
			return true
		end
	else
		values[char] = false
		if solve(index - 1) == true then
			return true
		end

		values[char] = true
		if solve(index - 1) == true then
			return true
		end
	end

	return false
end

print("\nTesting...")
solve()
print("\nResult: ".. #solutions .." solution(s)\n")

if #solutions > 0 then
	for i in pairs(solutions) do
		debug(solutions[i])
	end
end

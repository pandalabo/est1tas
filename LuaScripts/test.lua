count = 0

function recoursive()
	count = count + 1
	
	if count < 5 then
		recoursive()
		return 0
	end
	
	return 1
	
end

n = math.random(1)
print(n)
n = math.random(10)
print(n)

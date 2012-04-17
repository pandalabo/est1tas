require "mt19937"

--local randomseed = mt19937.randomseed
--local random = mt19937.random

mt19937.randomseed(os.time())
math.randomseed(os.time())
for i = 1, 10 do
    local rmt = mt19937.random(5)
    --local ri = math.floor(rf * 10)
	local r = math.random(5)
    print(rmt .. "\t" .. r)
end


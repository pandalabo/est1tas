local enccount
local encrate
local en1hp
local engrp = {}
local rand
local encpat
local fcount

while true do
	
--	emu.registerafter(function()

		engrp[1] = memory.readbytesigned(0x7e13f2)
		engrp[2] = memory.readbytesigned(0x7e13f3)
		engrp[3] = memory.readbytesigned(0x7e13f4)

		-- if we're in battle, display enemy hp & random number
		-- NOTICE: if you escape from a battle, then est1 does'nt initialize engrp num
		-- that causes mismatch of displayed info, like enemy hp info displayed, although we're not in battle
		if engrp[1] + engrp[2] + engrp[3] > -3 then
	
			rand = memory.readbyte(0x7e14ae)
        	en1hp = memory.readword(0x7ee542)
		
			gui.text(120, 216, "r:" .. string.format("%02d", rand) .. " \n"
				.. "en1HP:" .. en1hp)	

		-- gui.text is better
		--	snes9x.message("\n\nrand:" .. string.format("%02d", rand) .. "\n"
		--		.. "en1 HP:" .. en1hp)
		
		else

		-- if we're not, display random number & encounter count & random number
			
			enccount = memory.readbyte(0x7e078c)
			encrate = memory.readbyte(0x7e16c5)
			encpat = memory.readbyte(0x7e1476)
			rand = memory.readbyte(0x7e14ae)

			gui.text(120, 208, "rate:" .. encrate .. " " 
				.. "pat:" .. encpat)	
			gui.text(120, 216, "r:" .. string.format("%02d", rand) .. " "
				.. "step:" .. enccount)						

		--	snes9x.message("\n\n" .. "rand:" .. string.format("%02d", rand) .. "\n"
		--		.. "encounter:" .. enccount)
	
		end
	
--	end)

	snes9x.frameadvance();

end
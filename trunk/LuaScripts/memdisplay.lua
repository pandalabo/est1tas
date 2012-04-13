local enccount
local penc
local encrate
local en1hp
local engrp = {}
local rand
local rand2
local inbattle

while true do
	
	emu.registerafter(function()
	
		rand = memory.readbyte(0x7e14ae)
		rand2 = memory.readbyte(0x7e1476)
		
		gui.text(216,  1, "rand1:" .. string.format("%02d", rand))
		gui.text(216,  8, "rand2:" .. string.format("%02x", rand2))
		
		-- display random number & encounter count & random number
		
		enccount = memory.readbyte(0x7e078c)
		encrate = memory.readbyte(0x7e16c5)
		
		gui.text(200, 216, "enc_rate:" .. encrate)
		gui.text(200, 208, "encounter:" .. enccount)	

		-- if we're in battle, display enemy hp & random number
		-- NOTICE: if you escape from a battle, then est1 does'nt initialize engrp num
		-- that causes mismatch of displayed info, like enemy hp info displayed, although we're not in battle

		engrp[1] = memory.readbytesigned(0x7e13f2)
		engrp[2] = memory.readbytesigned(0x7e13f3)
		engrp[3] = memory.readbytesigned(0x7e13f4)

		if engrp[1] + engrp[2] + engrp[3] > -3 then
	
			enemy = 0
			
			if engrp[1] > -1 then enemy = enemy + engrp[1] end
			if engrp[2] > -1 then enemy = enemy + engrp[2] end
			if engrp[3] > -1 then enemy = enemy + engrp[3] end
	
        	en1hp = memory.readword(0x7ee542)	
			gui.text(  1,  96, "en1 HP:" .. en1hp)
			
			en2hp = memory.readword(0x7ee5C2)
			gui.text(  1, 104, "en2 HP:" .. en2hp)
		
			en3hp = memory.readword(0x7ee642)
			gui.text(  1, 112, "en3 HP:" .. en3hp)
		
			en4hp = memory.readword(0x7ee6C2)
			gui.text(  1, 120, "en4 HP:" .. en4hp)
			
			en4hp = memory.readword(0x7ee742)
			gui.text(  1, 128, "en5 HP:" .. en4hp)
			
			--ATPを取得
			p1atp = memory.readword(0x7E1700)
			p1atp_add = memory.readwordsigned(0x7E1730)
			p3atp = memory.readword(0x7E1704)
			p3atp_add = memory.readwordsigned(0x7E1734)
			
			gui.text( 20, 168, "ATP " .. p1atp .. " + " .. p1atp_add)
			gui.text(152, 168, "ATP " .. p3atp .. " + " .. p3atp_add)
			
		-- gui.text is better
		--	snes9x.message("\n\nrand:" .. string.format("%02d", rand) .. "\n"
		--		.. "en1 HP:" .. en1hp)
		
		else					
	
		end
	
	end)

	snes9x.frameadvance();

end
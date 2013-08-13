local enccount
local encrate
local engrp = {}
local rand
local rand2
local inbattle
local enemy_count = 0

while true do
	
	emu.registerafter(function()
	
		rand = memory.readbyte(0x7e14ae)
		rand2 = memory.readbyte(0x7e1476)
		
		gui.text(216,  1, "rnd idx:" .. string.format("%02d", rand))
		gui.text(216,  8, "r01:" .. string.format("%02x", rand2))
		
		-- display random number & encounter count & random number
		
		enccount = memory.readbyte(0x7e078c)
		encrate = memory.readbyte(0x7e16c5)
		
		gui.text(200, 216, "enc_rate:" .. encrate)
		gui.text(216, 208, "step:" .. enccount)	
		--ドロップアイテム
			drop = memory.readbyte(0x7e1430)
			gui.text(1, 80, "drop: " .. drop)

		-- if we're in battle, display enemy hp & random number
		-- NOTICE: if you escape from a battle, then est1 does'nt initialize engrp num
		-- that causes mismatch of displayed info, like enemy hp info displayed, although we're not in battle

		engrp[1] = memory.readbytesigned(0x7e13f2)
		engrp[2] = memory.readbytesigned(0x7e13f3)
		engrp[3] = memory.readbytesigned(0x7e13f4)
		engrp[4] = memory.readbytesigned(0x7e13f5)
		
		en1hp = memory.readword(0x7ee542)

		inbattle = ( engrp[1] + engrp[2] + engrp[3] + engrp[4] > -4 ) and en1hp ~= 21845
		
		if inbattle == true then
	
			enemy = 0
			
			if engrp[1] > -1 then enemy = enemy + engrp[1] end
			if engrp[2] > -1 then enemy = enemy + engrp[2] end
			if engrp[3] > -1 then enemy = enemy + engrp[3] end
			if engrp[4] > -1 then enemy = enemy + engrp[4] end

			if enemy_count == 0 then
				enemy_count = enemy
			end
			gui.text( 1, 88, "enemy: " .. enemy_count)
			
			en1hp = memory.readword(0x7ee542)	
			gui.text(  1,  96, "en1 HP:" .. en1hp)
			
			if enemy_count >= 2 then
				en2hp = memory.readword(0x7ee5C2)
				gui.text(  1, 104, "en2 HP:" .. en2hp)
			end
		
			if enemy_count >= 3 then
				en3hp = memory.readword(0x7ee642)
				gui.text(  1, 112, "en3 HP:" .. en3hp)
			end
			
			if enemy_count >= 4 then
				en4hp = memory.readword(0x7ee6C2)
				gui.text(  1, 120, "en4 HP:" .. en4hp)
			end
			
			if enemy_count >= 5 then
				en5hp = memory.readword(0x7ee742)
				gui.text(  1, 128, "en5 HP:" .. en4hp)
			end
			
			if enemy_count >= 6 then
				en6hp = memory.readword(0x7ee7C2)
				gui.text(  1, 136, "en6 HP:" .. en4hp)
			end
			
			--キャラの並び順に合わせて表示する
			char1st = memory.readbyte(0x7E14E2)
			char2nd = memory.readbyte(0x7E14E3)
			char3rd = memory.readbyte(0x7E14E4)
			char4th = memory.readbyte(0x7E14E5)
			
			--アグロスの位置を特定する
			aguro_place = 0
			if char2nd == 2 then aguro_place = 2 end
			if char3rd == 2 then aguro_place = 3 end
			if char4th == 2 then aguro_place = 4 end
			
			
			--ATPを取得
			p1atp = memory.readword(0x7E1700) --主人公
			p1atp_add = memory.readwordsigned(0x7E1730)
			p3atp = memory.readword(0x7E1704) --アグロス
			p3atp_add = memory.readwordsigned(0x7E1734)
			
			gui.text( 20, 168, "ATP " .. p1atp .. " + " .. p1atp_add)	
			if aguro_place == 2 then
				gui.text(152, 168, "ATP " .. p3atp .. " + " .. p3atp_add)
			elseif aguro_place == 3 then
				gui.text(20, 216, "ATP " .. p3atp .. " + " .. p3atp_add)
			elseif aguro_place == 4 then
				gui.text(140, 216, "ATP " .. p3atp .. " + " .. p3atp_add)
			else
				gui.text( 20, 168, "ATP " .. p3atp .. " + " .. p3atp_add)
			end
			
			--DFPを取得
			p1dfp = memory.readword(0x7E1708)
			p1dfp_add = memory.readwordsigned(0x7E1738) 
			
			gui.text( 68, 176, "DFP " .. p1dfp .. " + " .. p1dfp_add)
			
			--AGLを取得
			p1agl = memory.readword(0x7E1710)
			p1agl_add = memory.readwordsigned(0x7E1740) 
			
			gui.text( 20, 176, "AGL " .. p1agl .. " + " .. p1agl_add)
			
			
			
		-- gui.text is better
		--	snes9x.message("\n\nrand:" .. string.format("%02d", rand) .. "\n"
		--		.. "en1 HP:" .. en1hp)
		
		else					
	
		end
	
	end)

	emu.frameadvance();

end
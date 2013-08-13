require "mylib"

local enccount
local penc
local encrate
local en1hp
local engrp = {}
local rand
local rand2
local inbattle
local enemy_count = 0

local movielen

function display_all()
		
	gui.text(1, 1, adj_len(emu.framecount(), string.len(movie.length()) ) .. "/" .. movie.length())
	gui.text(1, 8, "lag: " .. emu.lagcount() )
	if emu.lagged() then
		gui.text(38, 8, "*")
	end
	gui.text(60,1, frame_to_timestr(emu.framecount()))

	rand = memory.readbyte(0x7E149E)
	rand2 = memory.readbyte(0x7e1476)
	
	gui.text(200,  1, "rand index:" .. string.format("%02d", rand))
	--gui.text(216,  8, "rand2:" .. string.format("%02x", rand2))
	
	-- display random number & encounter count
	
	enccount = memory.readbyte(0x7e078c)
	encrate = memory.readbyte(0x7e16c5)
	
	--gui.text(200, 216, "enc_rate:" .. encrate)
	--gui.text(200, 208, "encounter:" .. enccount)	

	-- if we're in battle, display enemy hp & random number
	-- NOTICE: when you escape from a battle, then est1 does'nt initialize engrp num
	-- that causes mismatch of displayed info, like enemy hp info displayed, although we're not in battle

	engrp[1] = memory.readbytesigned(0x7e13e2)
	engrp[2] = memory.readbytesigned(0x7e13e3)
	engrp[3] = memory.readbytesigned(0x7e13e4)
	engrp[4] = memory.readbytesigned(0x7e13e5)

	--初期化されていないおかしな値は表示しない
	if engrp[1] + engrp[2] + engrp[3] + engrp[4] > -4 
		and ( emu.framecount() > 11785 and not( 61996 < emu.framecount() and emu.framecount() < 81325) ) then
		
		enemy = 0
		
		if engrp[1] > -1 then enemy = enemy + engrp[1] end
		if engrp[2] > -1 then enemy = enemy + engrp[2] end
		if engrp[3] > -1 then enemy = enemy + engrp[3] end
		if engrp[4] > -1 then enemy = enemy + engrp[4] end
		
		if enemy_count == 0 then
			enemy_count = enemy
		end
		
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
		
		--ATPを取得
		p1atp = memory.readword(0x7E1700)
		p1atp_add = memory.readwordsigned(0x7E1730)
		p3atp = memory.readword(0x7E1704)
		p3atp_add = memory.readwordsigned(0x7E1734)
		
		--gui.text( 20, 168, "ATP " .. p1atp .. " + " .. p1atp_add)
		--gui.text(152, 168, "ATP " .. p3atp .. " + " .. p3atp_add)
	else
		enemy_count = 0
	end

end

function display_time()
	gui.text(2,1, frame_to_timestr(emu.framecount()))
end

while true do
	
	if movie.length() ~= 0 then
		emu.registerafter(display_all)
	else
		emu.registerafter(display_time)
	end

	snes9x.frameadvance();

end
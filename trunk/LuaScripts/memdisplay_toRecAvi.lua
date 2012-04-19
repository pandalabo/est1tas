local enccount
local penc
local encrate
local en1hp
local engrp = {}
local rand
local rand2
local inbattle

--len = 6, str = 111  -> should be "___111"
function adj_len(str, len)

	local str_ = str
	
	for i=1, len - string.len(str) do
		str_ = " " .. str_
	end
	return str_
end

function frame_to_timestr(f)

	local millisec
	local sec
	local minute
	local hour
	
	millisec = math.floor((f%60)/60*100)
	sec = math.floor(f/60)
	minute = math.floor(sec/60)
	hour = math.floor(minute/60)
	
	return ( hour .. ":" 
		.. string.format("%02d", minute%60) .. ":" 
		.. string.format("%02d", sec%60) .. "." 
		.. string.format("%02d", millisec) )
end

local movielen

function display_all()
		
	gui.text(1, 1, adj_len(emu.framecount(), string.len(movie.length()) ) .. "/" .. movie.length())
	gui.text(1, 8, "lag: " .. emu.lagcount() )
	if emu.lagged() then
		gui.text(38, 8, "*")
	end
	gui.text(60,1, frame_to_timestr(emu.framecount()))

	rand = memory.readbyte(0x7e14ae)
	rand2 = memory.readbyte(0x7e1476)
	
	gui.text(216,  1, "rand1:" .. string.format("%02d", rand))
	gui.text(216,  8, "rand2:" .. string.format("%02x", rand2))
	
	-- display random number & encounter count
	
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

	--初期化されていないおかしな値は表示されてしまう12000フレーム以前は情報を表示しない
	if engrp[1] + engrp[2] + engrp[3] > -3 
		and ( emu.framecount() > 11990 and not( 71580 < emu.framecount() and emu.framecount() < 88423) ) then

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
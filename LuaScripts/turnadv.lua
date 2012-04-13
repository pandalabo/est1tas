-- skip until one of our party member gets a turn, then pause.
local turn
local loop

loop = true
--emu.speedmode("nothrottle")

while loop do
		
	emu.registerafter(function()
		turn = memory.readbyte(0x7e1434)

		if turn ~= 255 then
			loop = false
			emu.pause()
			gui.text(100, 100, "char No." .. turn+1 .." has a turn")
			--gui.popup("got a turn", 'ok', 'warning') -- doesnt work properly
--			emu.speedmode("normal")
			emu.registerafter(nil)
			
		end
	end)
	emu.frameadvance()
end



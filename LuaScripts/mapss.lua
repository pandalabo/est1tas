
local flag --処理フラグ
local px
local py
local hx --主人公X座標
local hy --主人公Y座標

while true do
	
	flag = 0 --何もしない状態
	px = memory.readword(0x7e005a)
	py = memory.readword(0x7e005c)
	hx = px
	hy = py
	
	kbc = input.get()

	--上移動
	if kbc.R then 
		while py - hy <= 13 do
			
			joypad.set(1, {up=true})
			emu.frameadvance()
			hx = memory.readword(0x7e005a)
			hy = memory.readword(0x7e005c)
			if hy > py then
				hy = hy - 256
			end
		end
		flag = 1
	end	
	
	--下移動
	if kbc.C then 
		while hy - py < 13 do
			
			joypad.set(1, {down=true})
			emu.frameadvance()
			hx = memory.readword(0x7e005a)
			hy = memory.readword(0x7e005c)
			if py > hy then
				hy = hy + 256
			end
		end
		flag = 1
	end
	
	--左移動
	if kbc.D then 
		while px - hx <= 15 do
			
			joypad.set(1, {left=true})
			emu.frameadvance()
			hx = memory.readword(0x7e005a)
			hy = memory.readword(0x7e005c)
			if hx > px then
				hx = hx - 320
			end
		end
		flag = 1
	end	
	
	--右移動
	if kbc.F then 
		while hx - px < 15 do
			
			joypad.set(1, {right=true})
			emu.frameadvance()
			hx = memory.readword(0x7e005a)
			hy = memory.readword(0x7e005c)
			if px > hx then
				hx = hx + 320
			end
		end
		flag = 1
	end
	
	if flag == 1 then
	
		for c = 1, 16 do
			emu.frameadvance()
		end
		require"gd"
		hx = memory.readword(0x7e005a)
		hy = memory.readword(0x7e005c)
		gdstr = gui.gdscreenshot()
		gd.createFromGdStr(gdstr):png("Screenshots/fmap_" 
			.. hx .. "_" .. hy ..".png")
	end
	
	emu.frameadvance()
end 
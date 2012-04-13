local frame	--現在検証中のフレーム
local search_count = 0

state = savestate.create(7) --slot7のステートを作成
savestate.load(state) --slot7をSL
flag = 2 --やり直しの状態を管理するフラグ
--[[0:やり直し開始, 1:1フレーム待ち状態,
2:待ち中, 3:乱数調整完了]]

--emu.speedmode("maximum")
emu.speedmode("turbo")
--emu.speedmode("nothrottle")

--セーブステートの都合上registerafterが必要になる
--フラグ管理関数をフレーム処理の直前にコールバックさせる
emu.registerafter( function()
	if flag == 0 then
		savestate.load(state) --やり直し開始であればSL
		flag = 1 --フラグを1に進める	
	elseif flag == 1 then --フラグが1であれば	
		savestate.save(state) --1フレーム進めた状態をSS
		flag = 2 --フラグを2に進める
	end
end)

--描画は不要

while true do
	if flag == 2 then
	--待ち中であれば、Aを押し続ける
	joypad.set(1,{A=true})
		frame = emu.framecount()
		search_count = search_count + 1
		print("searching at " .. frame-1 .. "frame, count " .. search_count)

		--ここに結果の判定方法を書く
		
		--一定フレーム待機
		for i=0, 1000 do
			emu.frameadvance()
		end
		
		--目的の敵HPが目標値になっていれば調整終了
		en1hp = memory.readword(0x7ee542)
		en2hp = memory.readword(0x7ee5C2)
		en3hp = memory.readword(0x7ee642)
		en4hp = memory.readword(0x7ee6C2)
		
		if  en1hp == 0 then
			flag = 3 --乱数調整終了
		else
			flag = 0 --フラグをやり直しにする
		end
	
	end

	if flag == 3 then --乱数調整フラグが立ったら
		print("end") --終了したことを示すためにendを表示
		break --無限ループから脱出
	end
	
	emu.frameadvance() --1フレーム進める
	
end
emu.speedmode("normal")
emu.pause() --エミュレーターを一時停止
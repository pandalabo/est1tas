require "mylib9x"

--保存したステートから戦闘開始するための入力
function start_command()
	--print("started")
	fadv(1)
	joypad.set(1,{A=true})
	fadv(1)
end

--通常攻撃
function weapon_attack()
	joypad.set(1,{A=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(2)
end

--防御
function guard()
	joypad.set(1,{A=true,right=true})
	fadv(2)
end

trick_00_count = 0	--トゥイークの使用回数に制限
--トゥイーク⇒No.00(アーティ→マキシム)
function trick_00()
	
	trick_00_count = trick_00_count + 1 
	
	joypad.set(1,{A=true,up=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{A=true})
	fadv(3)
	
end

trick_01_count = 0	--トゥイークの使用回数に制限
--トゥイーク⇒No.01(ガイ)
function trick_01()

	trick_01_count = trick_01_count + 1 
	
	joypad.set(1,{A=true,up=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{right=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(3)
end

--ミラクロース⇒No.00（マキシム）
function miracle_00()
	joypad.set(1,{A=true,left=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{A=true})
	fadv(3)
end

--ミラクロース⇒No.01（ガイ）
function miracle_01()
	joypad.set(1,{A=true,left=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{right=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(3)

end

--ミラクロース⇒No.02（アーティ）
function miracle_02()
	joypad.set(1,{A=true,left=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{down=true})
	fadv(2)
	joypad.set(1,{right=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(3)
end

dread_count = 0	--ドリッド使用回数に制限
--ドリッド（アーティ）
function dread()

	dread_count = dread_count + 1

	joypad.set(1,{A=true,up=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{down=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{A=true})
	fadv(3)
end

--レ・ギオン（セレナ）
function thunder()
	joypad.set(1,{A=true,up=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{A=true})
	fadv(3)
end

local mirror_00_count = 0 --ミラール経過ターン制御（2ターンは同キャラにかけない）

--ミラール⇒No.00（マキシム）
function mirror_00()
	joypad.set(1,{A=true,up=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{right=true})
	fadv(2)
	local turn = memory.readbyte(0x7e1434)
	if turn == 2 then --セレナ
		joypad.set(1,{up=true})
	else	--アーティ
		joypad.set(1,{down=true})
	end
	fadv(2)
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{A=true})
	fadv(3)
end

local mirror_01_count = 0 --ミラール経過ターン制御（2ターンは同キャラにかけない）

--ミラール⇒No.01（ガイ）
function mirror_01()
	joypad.set(1,{A=true,up=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{right=true})
	fadv(2)
	local turn = memory.readbyte(0x7e1434)
	if turn == 2 then --セレナ
		joypad.set(1,{up=true})
	else	--アーティ
		joypad.set(1,{down=true})
	end
	fadv(2)
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{right=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(3)
end

local mirror_02_count = 0 --ミラール経過ターン制御（2ターンは同キャラにかけない）

--ミラール⇒No.02（セレナ）
function mirror_02()
	joypad.set(1,{A=true,up=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{right=true})
	fadv(2)
	local turn = memory.readbyte(0x7e1434)
	if turn == 2 then --セレナ
		joypad.set(1,{up=true})
	else	--アーティ
		joypad.set(1,{down=true})
	end
	fadv(2)
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{down=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(3)
end

local mirror_03_count = 0 --ミラール経過ターン制御（2ターンは同キャラにかけない）

--ミラール⇒No.03（アーティ）
function mirror_03()
	joypad.set(1,{A=true,up=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{right=true})
	fadv(2)
	local turn = memory.readbyte(0x7e1434)
	if turn == 2 then --セレナ
		joypad.set(1,{up=true})
	else	--アーティ
		joypad.set(1,{down=true})
	end
	fadv(2)
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{down=true})
	fadv(2)
	joypad.set(1,{right=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(3)
end

--戦闘ロジック用変数をリセット
function reset_var()
	trick_00_count = 0
	trick_01_count = 0
	dread_count = 0
	mirror_00_count = 0
	mirror_01_count = 0
	mirror_02_count = 0
	mirror_03_count = 0
end
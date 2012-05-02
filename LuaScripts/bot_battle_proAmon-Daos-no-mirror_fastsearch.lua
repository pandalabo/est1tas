--[[
	ランダム行動を複数回試行し、最も結果が良かったものを採用する
	全行動パターンの組み合わせを考えると、億をかるく超えるため処理不可 20^8 くらい?
	ある程度経験則からBOTに取らせる行動を限定し、少ない試行で最適解に近いものを探す
	戦闘突入直前の初期ステートをSL5から読み込む
	最新の撃破状態をSL6,最短撃破状態をSL7に保存
	prologueのアモン、ディオス用
]]

--use Mersenne Twister RNG, cuz math.rand from C Library is a bad algorithm
require "mt19937"

local search_count = 0 --初期フレームからの試行回数

--調査の限界
--超過した場合、遅すぎるので中断（手動戦闘結果より遅かったら意味がない）
local max_frame = 50000 --戦闘終了時（敵HPが0になった瞬間）の基準フレーム
local max_search = 200 --戦闘開始を遅らせて試行を始める最大フレーム数

local try_count = 200 --1つの戦闘開始フレームに対し、BOT戦闘を試行する回数

--調査中の最良結果フレーム
local best_frame = 9999999

--調査中の勝利回数とかも表示した方がLuaを中断する目安になっていい・・？


--botによるre-recordカウントをスキップするか *defualt false
movie.rerecordcounting(false)
print("re-recordcount: " .. movie.rerecordcount())

--現在時刻で乱数を初期化
mt19937.randomseed(os.time())

state = savestate.create(5) --ステートを作成

emu.speedmode("maximum")
--emu.speedmode("turbo")
--emu.speedmode("nothrottle")
--emu.speedmode("normal") --test use

local result = false

--frameadvance( n time(s))
function fadv(n)
	for i=1,n do 
		emu.frameadvance()
	end
end

--保存したステートから戦闘開始するための入力
function start_command()
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

local trick_00_count = 0	--トゥイークの使用回数に制限
--トゥイーク⇒No.00(マキシム)
function trick_00()
	
	trick_00_count = trick_00_count + 1 
	
	joypad.set(1,{A=true,up=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{down=true})
	fadv(2)
	joypad.set(1,{down=true})
	fadv(2)
	joypad.set(1,{right=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{A=true})
	fadv(3)
	
end

local trick_01_count = 0	--トゥイークの使用回数に制限
--トゥイーク⇒No.01(ガイ)
function trick_01()

	trick_01_count = trick_01_count + 1 
	
	joypad.set(1,{A=true,up=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{down=true})
	fadv(2)
	joypad.set(1,{down=true})
	fadv(2)
	joypad.set(1,{right=true})
	fadv(2)
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

local dread_count = 0	--ドリッド使用回数に制限
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

--各キャラの選択行動にはあまり状況判断ロジックを入れない
--⇒意外な行動が乱数調整に役立ち、結果短縮につながる可能性がある

--マキシムの行動
function pattern_00()

	--パーティのHPによる判断
	p1hp_max = memory.readword(0x7E16F0)
	p1hp = memory.readword(0x7E158F)
	p2hp_max = memory.readword(0x7E16F2)
	p2hp = memory.readword(0x7E1591)
	p3hp_max = memory.readword(0x7E16F4)
	p3hp = memory.readword(0x7E1593)
	p4hp_max = memory.readword(0x7E16F6)
	p4hp = memory.readword(0x7E1595)

	r = mt19937.random(5)
	if r == 1 then		
		-- if p4hp == 0 then --アーティが倒れていた場合
			-- miracle_02()
		-- else
			-- pattern_00()	--再度行動選択
		-- end
		
	-- elseif r == 2 then
		-- if p3hp == 0 then --ガイが倒れていた場合
			-- miracle_01()
		-- else
			-- pattern_00()	--再度行動選択
		-- end
		
		weapon_attack()
	else 
		weapon_attack()
	end
end

--セレナの行動
function pattern_01()

	--パーティのHPによる判断
	p1hp_max = memory.readword(0x7E16F0)
	p1hp = memory.readword(0x7E158F)
	p2hp_max = memory.readword(0x7E16F2)
	p2hp = memory.readword(0x7E1591)
	p3hp_max = memory.readword(0x7E16F4)
	p3hp = memory.readword(0x7E1593)
	p4hp_max = memory.readword(0x7E16F6)
	p4hp = memory.readword(0x7E1595)
	
	--パーティの状態による判断（正常：0、まひ：+1、せきか：+2、どく：+16、戦闘不能：+32、ムージル：+64）
	p1st = memory.readbyte(0x7E158B) --マキシム状態
	p2st = memory.readbyte(0x7E158C) --セレナ状態
	p3st = memory.readbyte(0x7E158D) --ガイ状態
	p4st = memory.readbyte(0x7E158E) --アーティ状態
	
	r = mt19937.random(4)
	if r == 1 or r == 2 then
		thunder()
	elseif r == 3 then
		weapon_attack()
	else
		guard()
	end
	
end

--ガイの行動
function pattern_02()

	--パーティのHPによる判断
	p1hp_max = memory.readword(0x7E16F0)
	p1hp = memory.readword(0x7E158F)
	p2hp_max = memory.readword(0x7E16F2)
	p2hp = memory.readword(0x7E1591)
	p3hp_max = memory.readword(0x7E16F4)
	p3hp = memory.readword(0x7E1593)
	p4hp_max = memory.readword(0x7E16F6)
	p4hp = memory.readword(0x7E1595)

	--マキシム、アーティが倒れている場合はミラクロースを使用する確率を上げる
	-- if p1hp == 0 then
		-- r = mt19937.random(3)
		-- if r >= 2 then
			-- miracle_00()
			-- return
		-- end
	-- end
	
	-- if p4hp == 0 then
		-- r = mt19937.random(3)
		-- if r >= 2 then
			-- miracle_02()
			-- return
		-- end
	-- end

	r = mt19937.random(6)
	if r == 1 then
		weapon_attack()
	else
		weapon_attack()
	end
end

--アーティの行動
function pattern_03()

	--パーティのHPによる判断
	p1hp_max = memory.readword(0x7E16F0)
	p1hp = memory.readword(0x7E158F)
	p2hp_max = memory.readword(0x7E16F2)
	p2hp = memory.readword(0x7E1591)
	p3hp_max = memory.readword(0x7E16F4)
	p3hp = memory.readword(0x7E1593)
	p4hp_max = memory.readword(0x7E16F6)
	p4hp = memory.readword(0x7E1595)
	
	--パーティの状態による判断（正常：0、まひ：+1、せきか：+2、どく：+16、戦闘不能：+32、ムージル：+64）
	p1st = memory.readbyte(0x7E158B) --マキシム状態
	p2st = memory.readbyte(0x7E158C) --セレナ状態
	p3st = memory.readbyte(0x7E158D) --ガイ状態
	p4st = memory.readbyte(0x7E158E) --アーティ状態
		
	--マキシム、ガイが倒れている場合はミラクロースを使用する確率を上げる
	-- if p1hp == 0 then
		-- r = mt19937.random(3)
		-- if r >= 2 then
			-- miracle_00()
			-- return
		-- end
	-- end
	
	-- if p3hp == 0 then
		-- r = mt19937.random(3)
		-- if r >= 2 then
			-- miracle_01()
			-- return
		-- end
	-- end

	r = mt19937.random(5)
	if r == 1 then
		--マキシムが生きていればトゥイークを使用（3回まで）
		if p1hp > 0 and trick_00_count < 3 then
			trick_00()	
		else
			pattern_03()	--再度行動選択
		end
	elseif r == 2 then
		--ガイが生きていればトゥイークを使用（3回まで）
		if p3hp > 0 and trick_01_count < 3 then
			trick_01()	
		else
			pattern_03()	--再度行動選択
		end
	elseif r == 3 then
		weapon_attack()
	elseif r == 4 then --ミラールでドリッドをはじくことを期待して使わない
		--ドリッドは2回まで、ムージルの状態でない
		if dread_count < 2 and  p4st < 64 then
			dread()
		else
			pattern_03() --再度行動選択
		end
	else
		guard()
	end
end

--ターンを持っているキャラを判断※0x7e1434の値は隊列依存
function input_command()

	local turn = memory.readbyte(0x7e1434)
	
	--[[
		以下の隊列の場合
		00:マキシム	01:ガイ
		02:セレナ	    03:アーティ
	]]
	--マキシムのターン
	if turn == 0 then
		mirror_00_count = mirror_00_count - 1	--ミラール経過ターンのカウント
		pattern_00()
	end
	
	--セレナのターン
	if turn == 2 then
		mirror_02_count = mirror_02_count - 1	--ミラール経過ターンのカウント
		pattern_01()
	end
	
	--ガイのターン
	if turn == 1 then
		mirror_01_count = mirror_01_count - 1	--ミラール経過ターンのカウント
		pattern_02()
	end
	
	--アーティのターン
	if turn == 3 then
		mirror_03_count = mirror_03_count - 1	--ミラール経過ターンのカウント
		pattern_03()
	end

end

--戦闘中に失敗と判断する基準
function failure()
	
	--失敗条件を満たしたら、フラグをtrueにする
	local fail_flag = false
	
	--予期せぬ動作でbotが停止した場合や戦闘が長い場合はmaxフレーム超過でリトライ
	if max_frame < emu.framecount() then
		fail_flag = true
	end
	
	local total_damage = 0
	
	--パーティのHPによる判断
	p1hp_max = memory.readword(0x7E16F0)
	p1hp = memory.readword(0x7E158F)
	p2hp_max = memory.readword(0x7E16F2)
	p2hp = memory.readword(0x7E1591)
	p3hp_max = memory.readword(0x7E16F4)
	p3hp = memory.readword(0x7E1593)
	p4hp_max = memory.readword(0x7E16F6)
	p4hp = memory.readword(0x7E1595)
	
	--パーティの状態による判断（正常：0、まひ：+1、せきか：+2、どく：+16、戦闘不能：+32、ムージル：+64）
	p1st = memory.readbyte(0x7E158B) --マキシム状態
	p2st = memory.readbyte(0x7E158C) --セレナ状態
	p3st = memory.readbyte(0x7E158D) --ガイ状態
	p4st = memory.readbyte(0x7E158E) --アーティ状態
	
	
	--全員が倒れた場合、失敗
	if p1hp == 0 and p2hp == 0 and p3hp == 0 and p4hp == 0 then	--セレナは抜けているため除外
		fail_flag = true
	end
		
	--失敗フラグが立っていなければ戦闘続行
	if fail_flag == false then
		return false
	end
	
	--上記条件以外
	return true

end

--bot試行内容
function attempt()
	
	--開始のための入力
	start_command()

	local turn = memory.readbyte(0x7e1434)	--戦闘中ターン所有
	-- FF:誰もターン持っていない（もしくは戦闘中でない）
	-- 00:1人目, 01:2人目, 02:3人目, 03:4人目
	
	local wait = true
	--戦闘開始～だれかがターンを持つまでフレームを進める
	while wait do

		emu.frameadvance()
		turn = memory.readbyte(0x7e1434)
		if turn ~= 255 then
			wait = false
		end
	end
	
	--戦闘中の判定
	local loop = true
	while loop do
	
		--ターンがある場合行動させる
		if turn ~= 255 then
			input_command()
		end
			
		en1hp = memory.readword(0x7EE542) --敵1HP
		
		--失敗条件を満たすか、ターゲットのHPが0になったら終了
		if failure() then
			result = false
			break
		end
		
		if en1hp == 0 then
			--print("enhp is 0")
			result = true
			break
		end
		
		emu.frameadvance()
		turn = memory.readbyte(0x7e1434)
		
	end
	
	reset_var() --戦闘ロジック用変数をリセット

end

--bot成功判定 
function success()
		
	--撃破時に誰かが倒れていた場合、失敗
	p1hp = memory.readword(0x7E158F)
	p2hp = memory.readword(0x7E1591)
	p3hp = memory.readword(0x7E1593)
	p4hp = memory.readword(0x7E1595)
	if p1hp == 0 or p2hp == 0 or p3hp == 0 or p4hp == 0 then
		return false
	end
		
	return result
end

--探索処理開始時のフレームを取得
savestate.load(state)
local beginning_frame = emu.framecount()

--BOT探索のメインループ
while true do

	print("try at " .. beginning_frame-1+search_count .. " frame(+" .. search_count .. ")")
		
	--botによるN戦闘試行
	for i=1, try_count do
	
		--次の試行のためにステートロード
		savestate.load(state)
		fadv(search_count)	--試行フレームまで進める
		
		attempt()	--戦闘
		
		--成功？か判断し、成功状態を保存する
		if success() then
			
			if emu.framecount() < best_frame then
				local state_best = savestate.create(7)
				savestate.save(state_best) --最短を保存
				
				best_frame = emu.framecount()
				max_frame = best_frame + 60	--今後の探索では最短結果より遅い場合打ち切る
				
				print("best state is saved, framecount: " .. best_frame 
					.."(+ wait:" .. search_count .. ", battle:" .. best_frame - beginning_frame - search_count .. ")" )
			else
				local state_good = savestate.create(6)
				savestate.save(state_good)	--成功状態を保存
			end
			
		end
		
		result = false --撃破フラグをリセット

	end
	
	search_count = search_count + 1			
	
	if search_count > max_search then
		print("search end, for excess of max_search")
		break
	end
	
	
end

--終了処理
emu.speedmode("normal")
emu.pause() --エミュレーターを一時停止
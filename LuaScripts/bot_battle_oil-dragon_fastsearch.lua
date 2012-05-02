--[[
	ランダム行動を複数回試行し、最も結果が良かったものを採用する
	全行動パターンの組み合わせを考えると、億、兆の単位を超えるため処理不可
	20^8
]]

--use Mersenne Twister RNG, cuz math.rand from C Library is a bad algorithm
require "mt19937"

--戦闘状況
local total_battle = 0
local win = 0
local total_damage = 0
local total_damage_inthistry = 0
local enhp_max = 0
local enhp_max_r = 99999
local max_damage = 0
local max_damage_inthistry = 0

--[[戦譜 separater:"\t" ex. PD0	PD1	A	A	G	M0
	A:Attack
	G:Guard
	M0:Miracle-> No.00
	D: doren
	PD0:Power Drug->No.00
]] 
local brec_hero = ""
local brec_aguro = ""
local brec_lufia = ""
local brec_jerin = ""

--ファイルに与ダメと一緒に記録？

local frame	--現在検証中のフレーム
local search_count = 0 --初期フレームからの試行回数

--調査の限界
--超過した場合、遅すぎるので中断（手動戦闘結果より遅かったら意味がない）
local max_frame = 16000 --戦闘終了時の基準フレーム
local max_search = 0 --戦闘開始を遅らせて試行を始める最大フレーム数

local try_count = 10000 --1つの戦闘開始フレームに対し、BOT戦闘を試行する回数

--調査中の最良結果フレーム
local best_frame = 9999999

--botによるre-recordカウントをスキップするか *defualt false
movie.rerecordcounting(false)
print("re-recordcount: " .. movie.rerecordcount())

--現在時刻で乱数を初期化
mt19937.randomseed(os.time())

state = savestate.create(5) --ステートを作成

emu.speedmode("maximum")
--emu.speedmode("nothrottle")
--emu.speedmode("normal") --test use

local result = false
local retry = false --maxフレーム超過した場合にtrue、戦闘失敗扱いにする

local last_act = -1
--コマンド文字列を受け取り、戦譜を記録する
function add_battle_rec(s)
	local turn = memory.readbyte(0x7e1434)
	
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
	p1st = memory.readbyte(0x7E158B) --主人公状態
	p2st = memory.readbyte(0x7E158C) --ルフィア状態
	p3st = memory.readbyte(0x7E158D) --アグロス状態
	p4st = memory.readbyte(0x7E158E) --ジュリナ状態
	
	local moveable = 0
	if p1hp > 0 and ( p1st == 0 or p1st%32 == 16 or p1st == 64 ) then moveable = moveable + 1 end
	if p2hp > 0 and ( p2st == 0 or p2st%32 == 16 or p2st == 64 ) then moveable = moveable + 1 end
	if p3hp > 0 and ( p3st == 0 or p3st%32 == 16 or p3st == 64 ) then moveable = moveable + 1 end
	if p4hp > 0 and ( p4st == 0 or p4st%32 == 16 or p4st == 64 ) then moveable = moveable + 1 end
	
	if last_act == turn and moveable > 1 then
		return
	end
	--[[
		以下の隊列の場合
		00:主人公	01:ジュリナ
		02:アグロス	03:ルフィア
	]]
	--主人公のターン
	if turn == 0 then
		brec_hero = brec_hero .. s .. "\t"
	end
	
	--ルフィアのターン
	if turn == 3 then
		brec_lufia = brec_lufia .. s .. "\t"
	end
	
	--アグロスのターン
	if turn == 2 then
		brec_aguro = brec_aguro .. s .. "\t"
	end
	
	--ジュリナのターン
	if turn == 1 then
		brec_jerin = brec_jerin .. s .. "\t"
	end
	
	last_act = turn
end

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

	add_battle_rec("A")
	
	joypad.set(1,{A=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(2)
end

--防御
function guard()

	add_battle_rec("G")
	
	joypad.set(1,{A=true,right=true})
	fadv(2)
end

local power_drug00_count = 0	--パワードラッグの使用回数に制限
--パワードラッグ⇒No.00(主人公)
function power_drug00()
	
	add_battle_rec("PD0")
	
	power_drug00_count = power_drug00_count + 1 
	
	joypad.set(1,{A=true,left=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{down=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{A=true})
	fadv(3)
	
end

local power_drug01_count = 0	--パワードラッグの使用回数に制限
--パワードラッグ⇒No.01(アグロス)
function power_drug01()

	add_battle_rec("PD1")

	power_drug01_count = power_drug01_count + 1 
	
	joypad.set(1,{A=true,left=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{down=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(4)
	--joypad.set(1,{right=true})
	joypad.set(1,{down=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(3)
end

--ミラクロース⇒No.00（主人公）
function miracle_00()
	
	add_battle_rec("M0")

	joypad.set(1,{A=true,left=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{up=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{A=true})
	fadv(3)
end

--ミラクロース⇒No.01（アグロス）
function miracle_01()

	add_battle_rec("M1")

	joypad.set(1,{A=true,left=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{up=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(4)
	--joypad.set(1,{right=true})
	joypad.set(1,{down=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(3)

end

--ミラクロース⇒No.02（ルフィア）
function miracle_02()

	add_battle_rec("M2")

	joypad.set(1,{A=true,left=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{up=true})
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

--ミラクロース⇒No.03（ジュリナ）
function miracle_03()

	add_battle_rec("M3")

	joypad.set(1,{A=true,left=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{up=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(4)
	-- joypad.set(1,{down=true})
	-- fadv(2)
	joypad.set(1,{right=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(3)
end

--ドレン（ルフィア）
local doren_count = 0	--ドレン使用回数に制限

function doren()

	add_battle_rec("D")
	
	doren_count = doren_count + 1

	joypad.set(1,{A=true,up=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{up=true})
	fadv(2)
	joypad.set(1,{up=true})
	fadv(2)
	joypad.set(1,{right=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{A=true})
	fadv(3)
end

--エストナ（ルフィア）
function estna()
	joypad.set(1,{A=true,up=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{A=true})
	fadv(3)
end

local miracle_used = false

--ミラクロース（共通）
function miracle()
	miracle_used = false
	
		--パーティのHPによる判断
	p1hp_max = memory.readword(0x7E16F0)
	p1hp = memory.readword(0x7E158F)
	p2hp_max = memory.readword(0x7E16F2)
	p2hp = memory.readword(0x7E1591)
	p3hp_max = memory.readword(0x7E16F4)
	p3hp = memory.readword(0x7E1593)
	p4hp_max = memory.readword(0x7E16F6)
	p4hp = memory.readword(0x7E1595)

	--主人公がHP低下している場合はミラクロースを使用する確率を上げる
	if p1hp < p1hp_max / 2 then
		r = mt19937.random(3)
		if r >= 2 then
			miracle_00()
			miracle_used = true
			return
		end
	end
	
	--ルフィアが倒れている場合はミラクロースを使用する確率を上げる
	if p2hp < p2hp / 2 then
		r = mt19937.random(3)
		if r >= 2 then
			miracle_02()
			miracle_used = true
			return
		end
	end
	
	--アグロス
	if p3hp < p3hp / 2 then
		r = mt19937.random(3)
		if r >= 2 then
			miracle_01()
			miracle_used = true
			return
		end
	end
	
	--ジュリナ
	if p4hp < p4hp / 2 then
		r = mt19937.random(3)
		if r >= 2 then
			miracle_03()
			miracle_used = true
			return
		end
	end
	
end

--戦闘ロジック用変数をリセット
function reset_var()
	power_drug00_count = 0
	power_drug01_count = 0
	doren_count = 0
end

--各キャラの選択行動にはあまり状況判断ロジックを入れない
--⇒意外な行動が乱数調整に役立ち、結果短縮につながる可能性がある

--主人公の行動
function pattern_00()
	r = mt19937.random(2)
	weapon_attack()
end

--ルフィアの行動
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
	
	--パーティの状態による判断（正常：0、まひ：+1、せきか：+2、どく：+16、戦闘不能：+32）
	p1st = memory.readbyte(0x7E158B) --主人公状態
	p3st = memory.readbyte(0x7E158D) --アグロス状態

	miracle()
	if miracle_used then
		return
	end
	
	r = mt19937.random(5)
	if r == 1 then
		if p1st == 0 then
			if power_drug00_count < 3 then
				power_drug00()	--主人公が生きていればパワードラッグを使用（3回まで）
			else
				pattern_01() --再度行動選択
			end
		else
			pattern_01() --再度行動選択
		end
	elseif r == 2 then
		if p3st == 0 then
			if power_drug01_count < 3 then
				power_drug01()	--アグロスが生きていればパワードラッグを使用（3回まで）
			else
				pattern_01() --再度行動選択
			end
		else
			pattern_01() --再度行動選択
		end
	elseif r == 3 then
		--ドレンは2回まで
		if doren_count < 2 then
			pattern_01() --再度行動選択
		else
			doren()
		end
	elseif r == 4 then
		weapon_attack()
	else
		guard()
	end
	
end

--アグロスの行動
function pattern_02()
	
	miracle()
	if miracle_used then
		return
	end

	r = mt19937.random(4)
	if r == 1 then
		weapon_attack()
	else
		weapon_attack()
	end
end
--なぜかたまにアグロスが指定動作以外のことをする・・・⇒課題

--ジュリナの行動
function pattern_03()

	--パーティの状態による判断（正常：0、まひ：+1、せきか：+2、どく：+16、戦闘不能：+32）
	p1st = memory.readbyte(0x7E158B) --主人公状態
	p3st = memory.readbyte(0x7E158D) --アグロス状態

	miracle()
	if miracle_used then
		return
	end

	r = mt19937.random(5)
	if r == 1 then
		if p1st == 0 then
			if power_drug00_count < 3 then
				power_drug00()	--主人公が生きていればパワードラッグを使用（3回まで）
			else
				pattern_03() --再度行動選択
			end
		else
			pattern_03()	--再度行動選択
		end
	elseif r == 2 then
		if p3st == 0 then
			if power_drug01_count < 3 then
				power_drug01()	--アグロスが生きていればパワードラッグを使用（3回まで）
			else
				pattern_03() --再度行動選択
			end
		else
			pattern_03()	--再度行動選択
		end
	elseif r == 3 then
		weapon_attack()
	elseif r == 4 then
		miracle_01()
	else
		guard()
	end
end

--ターンを持っているキャラを判断※0x7e1434の値は隊列依存
function input_command()

	local turn = memory.readbyte(0x7e1434)
	
	--[[
		以下の隊列の場合
		00:主人公	01:アグロス
		02:ルフィア	03:ジュリナ
	]]
	--主人公のターン
	if turn == 0 then
		pattern_00()
	end
	
	--ルフィアのターン
	if turn == 3 then
		pattern_01()
	end
	
	--アグロスのターン
	if turn == 2 then
		pattern_02()
	end
	
	--ジュリナのターン
	if turn == 1 then
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
	--パーティの状態による判断（正常：0、まひ：+1、せきか：+2、どく：+16、戦闘不能：+32）
	p1st = memory.readbyte(0x7E158B) --主人公状態
	p2st = memory.readbyte(0x7E158C) --ルフィア状態
	p3st = memory.readbyte(0x7E158D) --アグロス状態
	p4st = memory.readbyte(0x7E158E) --ジュリナ状態
		
	--全員が倒れた場合、失敗
	if p1hp == 0 and ( p2hp == 0 or p2st%4 == 2 ) and p3hp == 0 and ( p4hp == 0 or p4st%4 == 2) then
		fail_flag = true
	end
	
	--[[
	--ドレンをミラールで反射された場合は失敗
	p2def = memory.readwordsigned(0x7E173A)
	
	if p2def ~= 0 then
		fail_flag = true
		--print("doren is reflected")
	end
	]]
	
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
	
	enhp_max = memory.readword(0x7EE542) --敵1HP
	
	--戦闘中の判定
	local loop = true
	while loop do
	
		--ターンがある場合行動させる
		if turn ~= 255 then
			input_command()
		end
			
		en1hp = memory.readword(0x7EE542) --敵1HP
		
		if en1hp == 0 then
			result = true
			break
		end
		
		if failure() then
			result = false
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
		
		total_battle = total_battle + 1
		attempt()	--戦闘
		
		total_damage = total_damage + enhp_max - memory.readword(0x7EE542)
		total_damage_inthistry = total_damage_inthistry + enhp_max - memory.readword(0x7EE542)
		
		--最大与ダメ記録の更新
		if enhp_max_r - max_damage > memory.readword(0x7EE542) then
			max_damage = enhp_max - memory.readword(0x7EE542)
			enhp_max_r = enhp_max
		end
		
		if enhp_max - memory.readword(0x7EE542) > max_damage_inthistry then
			max_damage_inthistry = enhp_max - memory.readword(0x7EE542)
		end
		
		--与ダメ一定以上の場合、戦譜をファイルに書き出し　（勝率が低いボス用に後で検証するため）
		if enhp_max - memory.readword(0x7EE542) > 4000 then
			file = io.open("oil-dragon_br.txt", "a+")
			file:write("--------------------------------------------------------\n")
			file:write(os.date("%Y-%m-%d %H:%M:%S") .. "\n")
			file:write("try frame: " .. beginning_frame-1+search_count .. "　"
				.. "damage:" .. enhp_max - memory.readword(0x7EE542) .. " "
				.. "time:" .. emu.framecount() - beginning_frame .. " frames" .. "\n" )
			file:write("hero:" .. brec_hero .. "\n")
			file:write("lufia:" .. brec_lufia .. "\n")
			file:write("aguro:" .. brec_aguro .. "\n")
			file:write("jerin:" .. brec_jerin .. "\n")
			file:close()
			
		end
		
		brec_hero, brec_lufia, brec_aguro, brec_jerin = "", "", "", ""
		
		--成功？か判断し、成功状態を保存する
		if success() then
			
			win = win + 1
			
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
	
	print("max:" .. max_damage .. "/" .. enhp_max_r .. "(this try: ".. max_damage_inthistry .. ")"
			.. ", ave:" .. math.floor(total_damage / total_battle)
			.. "(at " .. beginning_frame-1+search_count .."f:" .. math.floor(total_damage_inthistry/try_count) .. ")"
			.. ", win/battle:" .. win .. "/" .. total_battle
			.. ", win-rate:" .. string.format("%.2f", win/total_battle*100))
			
	total_damage_inthistry = 0	--あるフレームでのダメージ合計をリセット
	max_damage_inthistry = 0 --あるフレームでの最大ダメージをリセット
	
	--次フレームでの探索のためフレームを進める
	search_count = search_count + 1			
	
	--基準フレーム超過で探索終了
	if search_count > max_search then
		print("search end, for excess of max_search")
		break
	end
	
end

--終了処理
emu.speedmode("normal")
emu.pause() --エミュレーターを一時停止
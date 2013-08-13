
--[[
	ランダム行動を複数回試行し、最も結果が良かったものを採用する
	全行動パターンの組み合わせを考えると、億をかるく超えるため処理不可 20^8 くらい?
	ある程度経験則からBOTに取らせる行動を限定し、少ない試行で最適解に近いものを探す
	戦闘突入直前の初期ステートをSL5から読み込む
	最新の撃破状態をSL6,最短撃破状態をSL7に保存
	prologueのアモン、ディオス用
]]

--マキシムの行動
local pattern_00 = function pattern_00()

	memlist:updateMemberStatValue()

	r = mt19937.random(5)
	if r == 1 then		
		--アーティが倒れていた場合
		if memlist.p4hp == 0 then
			miracle_02()
		else
			pattern_00()	--再度行動選択
		end
		
	elseif r == 2 then
		--ガイが倒れていた場合
		if memlist.p3hp == 0 then
			miracle_01()
		else
			pattern_00()	--再度行動選択
		end
		
		weapon_attack()
	else 
		weapon_attack()
	end
end

--セレナの行動
local pattern_01 = function pattern_01()
	
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
local pattern_02 = function pattern_02()

	memlist:updateMemberStatValue()

	r = mt19937.random(6)
	if r == 1 then
		weapon_attack()
	else
		weapon_attack()
	end
end

--アーティの行動
local pattern_03 = function pattern_03()

	memlist:updateMemberStatValue()
		
	r = mt19937.random(5)
	if r == 1 then
		--マキシムが生きていればトゥイークを使用（3回まで）
		if memlist.p1hp > 0 and trick_00_count < 3 then
			trick_00()	
		else
			pattern_03()	--再度行動選択
		end
	elseif r == 2 then
		--ガイが生きていればトゥイークを使用（3回まで）
		if memlist.p3hp > 0 and trick_01_count < 3 then
			trick_01()	
		else
			pattern_03()	--再度行動選択
		end
	elseif r == 3 then
		weapon_attack()
	elseif r == 4 then
		--ドリッドは2回まで、ムージルの状態でない
		if dread_count < 2 and  memlist.p4st < 64 then
			dread()
		else
			pattern_03() --再度行動選択
		end
	else
		guard()
	end
end



--戦闘中に失敗と判断する基準
failure = function failure()
	
	--失敗条件を満たしたら、フラグをtrueにする
	local fail_flag = false
	
	--予期せぬ動作でbotが停止した場合や戦闘が長い場合はmaxフレーム超過でリトライ
	if max_frame < emu.framecount() then
		fail_flag = true
	end
	
	local total_damage = 0
	
	
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


--用意した関数をセット

bot_battle.pattern_00 = pattern_00
bot_battle.pattern_01 = pattern_01
bot_battle.pattern_02 = pattern_02
bot_battle.pattern_03 = pattern_03
--bot_battle.failure = failure

--BOT戦闘開始
bot_battle:start_bot_search()





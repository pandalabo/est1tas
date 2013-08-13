--[[
	ランダム行動を複数回試行し、最も結果が良かったものを採用する
	全行動パターンの組み合わせを考えると、億をかるく超えるため処理不可 20^8 くらい?
	ある程度経験則からBOTに取らせる行動を限定し、少ない試行で最適解に近いものを探す
	
	各キャラの選択行動にはあまり状況判断ロジックを入れない
    ⇒意外な行動が乱数調整に役立ち、結果短縮につながる可能性がある
	
	【使い方】
	戦闘突入直前の初期ステートをSL5から読み込む
	最新の撃破状態をSL6,最短撃破状態をSL7に保存 
]]

--TAS用ライブラリ
require "mylib9x"
--use Mersenne Twister RNG, cuz math.rand from C Library is a bad algorithm
require "mt19937"
--戦闘用コマンドを読み込み
require "battle_command"
--メモリリスト取得
require "est1mem"

bot_battle = {

	max_frame = 99999999, 
	max_search = 120, 
	try_count = 200, 
	failure = function()
			return false
		end, 
	finish = function()
			return false
		end, 
	success = function()
			return true
		end, 
	pattern_00 = nil, 
	pattern_01 = nil, 
	pattern_02 = nil, 
	pattern_03 = nil,

	start_bot_search = function(self)

		local frame	--現在検証中のフレーム
		local search_count = 0 --初期フレームからの試行回数

		--調査の限界
		--超過した場合、遅すぎるので中断（手動戦闘結果より遅かったら意味がない）
		--local max_frame = 25000 --戦闘終了時（敵HPが0になった瞬間）の基準フレーム (最適結果が出るたびに更新)
		--local max_search = 120 --戦闘開始を遅らせて試行を始める最大フレーム数

		--local try_count = 200 --1つの戦闘開始フレームに対し、BOT戦闘を試行する回数

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

		--探索処理開始時のフレームを取得
		savestate.load(state)
		local beginning_frame = emu.framecount()

		--BOT探索のメインループ
		while true do

			print("try at " .. beginning_frame-1+search_count .. " frame(+" .. search_count .. ")")
				
			--botによるN戦闘試行
			for i=1, self.try_count do
			
				--次の試行のためにステートロード
				savestate.load(state)
				fadv(search_count)	--試行フレームまで進める
				
				self.attempt()	--戦闘
				
				--成功？か判断し、成功状態を保存する
				if success() and self.default_success() then
					
					if emu.framecount() < best_frame then
						local state_best = savestate.create(7)
						savestate.save(state_best) --最短を保存
						
						best_frame = emu.framecount()
						self.max_frame = best_frame + 60	--今後の探索では最短結果より遅い場合打ち切る
						
						print("best state is saved, framecount: " .. best_frame .. "(" .. best_frame - beginning_frame .. ")" )
					else
						local state_good = savestate.create(6)
						savestate.save(state_good)	--成功状態を保存
					end
					
				end
				
				result = false --撃破フラグをリセット

			end
			
			search_count = search_count + 1			
			
			if search_count > self.max_search then
				print("search end, trying " .. self.max_search .. "times has finished")
				break
			end
			
			
		end

		--終了処理
		emu.speedmode("normal")
		emu.pause() --エミュレーターを一時停止

	end

	--ターンを持っているキャラを判断※0x7e1434の値は隊列依存
	input_command = function(self)

		local turn = memory.readbyte(0x7e1434)
		
		--[[
			以下の隊列の場合
			00:マキシム	01:ガイ
			02:セレナ	03:アーティ
		]]
		--マキシムのターン
		if turn == 0 then
			self.pattern_00()
		end
		
		--セレナのターン
		if turn == 2 then
			self.pattern_01()
		end
		
		--ガイのターン
		if turn == 1 then
			self.pattern_02()
		end
		
		--アーティのターン
		if turn == 3 then
			self.pattern_03()
		end

	end



	--bot試行内容
	attempt = function(self)
		
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
				self.input_command()
			end
				
			
			
			--失敗条件を満たすか、ターゲットのHPが0になったら終了
			if failure() and self.defalut_battle_failure() then
				result = false
				break
			end
			if finish() and self.defalut_battle_finish() then
				result = true
				break
			end
			
			emu.frameadvance()
			turn = memory.readbyte(0x7e1434)
			
		end
		
		reset_var() --戦闘ロジック用変数をリセット

	end
	
		--戦闘中に失敗と判断する基準
	defualt_battle_failure = function(self)
		
		--失敗条件を満たしたら、フラグをtrueにする
		local fail_flag = false
		
		--戦闘時間が最短結果＋α超過した場合失敗
		if self.max_frame < emu.framecount() then
			fail_flag = true
		end
		
		memlist:updateMemberStatValue()
		
		--全員が倒れた場合、失敗
		if memlist.p1hp == 0 and memlist.p2hp == 0 
			and memlist.p3hp == 0 and memlist.p4hp == 0 then
			fail_flag = true
		end
			
		--失敗フラグが立っていなければ戦闘続行
		return fail_flag

	end

	--戦闘が終了したと判断する条件
	default_battle_finish = function()
		local result = false
		en1hp = memory.readword(0x7EE542) --敵1HP
		if en1hp == 0 then
			result = true
		end
		
		return result
	end

	--bot戦闘 追加成功判定 
	default_success = function()
		local result = true
			
		--撃破時に誰かが倒れていた場合、失敗
		memlist:updateMemberStatValue()
		if memlist.p1hp == 0 or memlist.p2hp == 0 
			or memlist.p3hp == 0 or memlist.p4hp == 0 then
			return false
		end
			
		return result
	end

}




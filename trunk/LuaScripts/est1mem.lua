-- est1 memory get static class

--参考 http://www.hakkaku.net/articles/20081118-286

--もう少し研究がいるかも⇒　http://lua-users.org/wiki/ObjectOrientationTutorial

-- memory　list オブジェクトを作成
memlist = {
  p1hp_max = 1,
  p1hp  = 0,
  p2hp_max = 1,
  p2hp  = 0,
  p3hp_max = 1,
  p3hp  = 0,
  p4hp_max = 1,
  p4hp  = 0,
  p1st = 0,
  p2st = 0,
  p3st = 0,
  p4st = 0,
  
  updateMemberStatValue = function(self)
    --パーティのHPによる判断
	self.p1hp_max = memory.readword(0x7E16F0)
	self.p1hp = memory.readword(0x7E158F)
	self.p2hp_max = memory.readword(0x7E16F2)
	self.p2hp = memory.readword(0x7E1591)
	self.p3hp_max = memory.readword(0x7E16F4)
	self.p3hp = memory.readword(0x7E1593)
	self.p4hp_max = memory.readword(0x7E16F6)
	self.p4hp = memory.readword(0x7E1595)
	
	--パーティの状態による判断（正常：0、まひ：+1、せきか：+2、どく：+16、戦闘不能：+32、ムージル：+64）
	self.p1st = memory.readbyte(0x7E158B) --マキシム状態
	self.p2st = memory.readbyte(0x7E158C) --セレナ状態
	self.p3st = memory.readbyte(0x7E158D) --ガイ状態
	self.p4st = memory.readbyte(0x7E158E) --アーティ状態
  end
}


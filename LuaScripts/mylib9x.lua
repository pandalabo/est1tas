--TAS作成用自作Luaライブラリ

--frameadvance( n time(s))
function fadv(n)
	for i=1,n do 
		emu.frameadvance()
	end
end

--フレームカウントを時間表記文字列に変換
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

--len = 6, str = 111  -> should be "___111"
function adj_len(str, len)

        local str_ = str
        
        for i=1, len - string.len(str) do
                str_ = " " .. str_
        end
        return str_
end
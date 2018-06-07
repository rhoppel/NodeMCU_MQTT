p_line(_,'','The following executes at the end of the main.lua')

--[[
if p_fver then  p_fver() ; p_line() end

--if p_status then p_line(_,_,'status'); p_status() end
if init_clean then init_clean() ; p_line(_,_,"init_clean()") end


tmr.alarm(TMR.dly.n, 1500, tmr.ALARM_SINGLE, function() 
	init_clean2() 
	p_line(_,_,"Clean complete, start timers")
	tmr.alarm(TMR.dly.n, 500, tmr.ALARM_SINGLE, 
		function() 
--			MQTT = nil
--			AP = nil
			if init_clean2 then init_clean2() end
			p_line(_,_,"start OLED")
			dofile("oled_loop.lc")
			dofile('TMR_init.lua')
			dofile('updt_svr.lua')
			--dofile('M_init.lua')
		end)
	end)
--]]

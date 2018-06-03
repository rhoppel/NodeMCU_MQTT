 local fn,fp = "gpio", {"0.8","6/1/18","RLH"} if type(fver) == 'table' then fver[fn] = fp end 
if p_local_fver == nil then dofile("p_local_fver.lua") end
 if p_local_fver ~= nil then p_local_fver(fn,fp) end
 
 -- hardware functions

 --configure  gpio pin for pwm
 function pwmG(T,p,s) -- pin, start(T/F) optional
	-- could add data validation
	local i = tonumber(p)

	if i < 1 or i > D.pins - 1 then return end
	  if T[i].pwm then 
		print("pwmG: ",i, "start: ",s )
		if s == nil  then 
--			local f = T[i].freq or 500--
--			local d = T[i].duty or 512
--			pwm.setup(i,f,d) 
			print("pwmG[setup]: ",i,"pwm: ",T[i].pwm, "freq: ",T[i].freq,"duty: ",T[i].duty )
			pwm.setup(i,T[i].freq or 500,T[i].duty or 512) 
		elseif s == true then pwm.start(i)
		elseif s == false then pwm.stop(i)
		else 
			print("pwmG: ","ERROR" )
		end
	else pwm.close(i)
	end

end

 function pins_mode(T)
	local i 
	for i = 0 ,D.pins -1  do
		if T[i].m then
			--print("pins_mode: ",i, "mode: ",T[i].m)
			if T[i].pu then	gpio.mode(i, T[i].m, gpio.PULLUP )
			else gpio.mode(i, T[i].m)
			end
		end
		pwmG(T,i,nil)
	end

end

pins_mode(PINS)
--pins_mode = nil -- remove after using

function pins_rw()
	local T = PINS
	local r_chng = false
	local i

	for i = 0,D.pins - 1 do
		--print("pins_rw: ",i, type(i))
		local m = T[i].m
		if m then
			if  m == gpio.INPUT or m == gpio.INT then
				local x =  T[i].r
				T[i].r = gpio.read(i)
				r_chng = x ~= T[i].r or r_chng
				-- report only pin changes
			elseif m == gpio.OUTPUT or m == gpio.OPENDRAIN then
				gpio.write(i,T[i].w)
			end
		end
	end
	if r_chng then 
		if D.dbg then p_line(_,_,"INPUTs have changed") end
		--if D.mqtt ~= 'userdata' then print("INPUT changed but MQ not defined yet") end
		--if D.mqtt then mq:publish(P_TOP.data, sjson.encode({["data"] = 'ipins', ["ipins"] = pins_msg(PINS)}),0,0) end
		if D.mqtt then mqtt_pub_smsg(P_TOP.data, "ipins", pins_msg(PINS))
		else print("ERROR[pins_rw]: MQTT not connected")
		end
	end
    return r_chng
end 

TMR.rp.f = pins_rw
tmr_rst('rp')

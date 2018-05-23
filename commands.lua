local fn,fp = "commands", {"0.7b","4/8/18","RLH"} if type(fver) == 'table' then fver[fn] = fp end 
if p_local_fver ~= nil then p_local_fver(fn,fp) end

function cmd_process(C)
	if type(C.cmd) == 'string' then 
		if 	   C.cmd == "pins_config" then pins_config(PINS,C.pins)
		elseif C.cmd == "pwm" 		then pwm_updt(C.pin)
		elseif C.cmd == "pins" 		then mqtt_pub_smsg(P_TOP.data,'pins',PINS)
		elseif C.cmd == "device" 	then mqtt_pub_smsg(P_TOP.data,'',{D.ID,D})
		elseif C.cmd == "reset" 	then node.reset()
		elseif C.cmd == "pins_write" then pins_write(C.pins)
		elseif C.cmd == "scrn_io" 	then scrn_io()
		elseif C.cmd == "DEBUG" 	then D.dbg = not D.dbg
		elseif C.cmd == "t_cal" 	then D.t_cal = C.t_cal 
		elseif C.cmd == "name"		then D.name = C.name
		elseif C.cmd == "msg"		then D.msg = C.msg; if C.msg == "" then D.msg = nil end; screens() 
		--[[
		elseif C.cmd == "heap" then mqtt_pub_smsg(P_TOP.data,'heap',D.heap)
		elseif C.cmd == "adc_get" then adc_get() 
		elseif C.cmd == "uart_send" then pwm(C.pl)
		elseif C.cmd == "uart_config" then pwm(C.pins)
		--]]
		else
		print(C.cmd, "command not found"); 
		mqtt_pub_error("[commands] \'"..C.cmd.."\' command not implemented")
		end
    end
end

-- commands

-- alternate between the possible OLED screen modes 

function  scrn_io() 
	D.s_io = not D.s_io
	if D.s_io then
		tmr_rst('scrn', TMR.scrn.tio)
	else 
		tmr_rst('scrn')
	end
	print("Display IO only:",D.s_io )
end

-- write pin data from a command to PINS Object
function pins_write(X)
	--print(dump(X))
	for k,v in pairs(X) do
        local kk = tonumber(k)
        if PINS[kk].m == gpio.OUTPUT or PINS[kk].m == gpio.OPENDRAIN then
			if D.dbg then print(string.format("p[%s] was:%s now:%s",kk, PINS[kk].w, v )) end
			PINS[kk].w = v
		else 
			mqtt_pub_error("[commands] pin:"..kk.." is not a output")
		end
    end
end

function pins_config(T,U)  -- PIN CONSTRUCTOR
	for k,v in pairs(U) do
		local i = tonumber(k)
		--print("pins_config: i,U[i],U[i].m =",i,U[k],U[k].m)
		if U[k] and  U[k].m              -- only process additional info if mode is specified
			then 
				T[i] = {}			-- clear previous pin state
				T[i].m  = U[k].m	-- m (mode) {"","OUTPUT(1)","OPENDRAIN(3)","INPUT(0)","INT(2)"}
				if T[i].m == gpio.INPUT then T[i].r  = 0 end  -- r (read state) {"0","1"}
				if T[i].m == gpio.INT then T[i].r  = 0 end  -- r (read state) {"0","1"}
				T[i].w    = U[k].w	-- w (write) {"LOW","HIGH"} 
				T[i].pu   = U[k].pu	-- p (pullup type) {("PULLUP(1)"), (FLOAT(0))(default)}
				T[i].t    = U[k].t	-- t (trigger type) {"up", "down", "both", "low", "high"}
				T[i].pwm  = U[k].pwm -- pwm modulation on/off
				T[i].freq = U[k].freq -- pwm frequency (0 - 1000 Hz)
				T[i].duty = U[k].duty -- duty cycle (0-1024)
			else
				mqtt_pub_error("[commands] pin:"..k.." mode is not specified")		
			end
	end
end  
--  publish (MQTT) a simple JSON encoded message
function mqtt_pub_smsg(topic,key,value)
	if type(key)  == 'string' 	
	then 
		local x = {};
		x[key] = value 
		if key == '' then x = value end
		local json = sjson.encode(x)
		local t = topic..key
		--local json = '{"'.. key .. ':",' .. value ..'}'
		if D.dbg then p_line(60,_,"MQTT Publish: "..t); print(json) end
		mq:publish(t,json,0,0,function(client) if D.dbg then print("MQTT Publish:","\t\tdata received") end end)
	else print("Error C.cmd is not a string")
	end
end  

function mqtt_pub_error(msg)
	mqtt_pub_smsg(P_TOP.data,"error",msg)
end

-- return a msg object from either Input or Outputs pins current PINS Object
function pins_msg(T,w)  -- w = true if Output date is required  
    local X={}
    for k = 0, D.pins - 1  do
        local m = T[k].m
        if w and (m == gpio.OUTPUT or m == gpio.OPENDRAIN) then
            if D.dbg then print(string.format("Write: p[%s] = %s",k, T[k].w)) end
            X[tostring(k)]=T[k].w
        elseif not w and (m == gpio.INPUT or m == gpio.INT) then
            if D.dbg then print(string.format("Read: p[%s] = %s",k, T[k].r)) end
            X[tostring(k)]=T[k].r
        end
    end
    return X
end


local fn,fp = "commands", {"0.4a","1/8/18","RLH"} if type(fver) == 'table' then fver[fn] = fp end 
if p_local_fver ~= nil then p_local_fver(fn,fp) end

function cmd_process(C)
	if type(C.cmd) == 'string' then 
		if     C.cmd == "pins_list" then pins_list()
		elseif C.cmd == "pins" then pins_list()
		elseif C.cmd == "reset" then node.reset()
		elseif C.cmd == "pins_write" then pins_write(C.pins)
		elseif C.cmd == "scrn_io" then scrn_io()
		elseif C.cmd == "DEBUG" then debug2()
		elseif C.cmd == "heap" then heap()

			--[[
		elseif C.cmd == "pins_set_mode" then pins_mode(C.pins)
		elseif C.cmd == "pins_read" then pins_read(C.pins)
		elseif C.cmd == "adc_get" then adc_get() 
		elseif C.cmd == "pwm_config" then pwm(C.pins,C.pwm)
		elseif C.cmd == "pins_set" then pwm(C.pins)
		elseif C.cmd == "pins_config" then pwm(C.pins)
		elseif C.cmd == "uart_send" then pwm(C.pl)
		elseif C.cmd == "uart_config" then pwm(C.pins)
--]]
		else
		print(C.cmd, "command not found"); mqtt_pub_smsg(P_TOP.data,"error",C.cmd.." command not found")
		end
    end
end
-- commands
function  scrn_io() 
	D.s_io = not D.s_io
	if D.s_io then
		tmr_rst('scrn', TMR.scrn.tio)
	else 
		tmr_rst('scrn')
	end
end

function debug2() dbg = not dbg end

function heap() mqtt_pub_smsg(P_TOP.data,'heap',node.heap()) end 

function pins_list()
	mqtt_pub_smsg(P_TOP.data,'pins',PINS)
end 
--[[
pins_read   = function(T) print("rp?")end 
pins_change = function(T) print("cp?")end 
adc_get     = function(T) print("gadc?") end 
pwm_config  = function(T) print("pwm?")end 
--]]

function pins_write(X)
	--print(dump(X))
	for k,v in pairs(X) do
        local kk = tonumber(k)
        if PINS[kk].m == gpio.OUTPUT or PINS[kk].m == gpio.OPENDRAIN then
			if dbg then print(string.format("p[%s] was:%s now:%s",kk, PINS[kk].w, v )) end
			PINS[kk].w = v
        end
    end
end


-- MQTT publish a simple JSON encoded message
function mqtt_pub_smsg(topic,key,value)
	if type(key)  == 'string' 	
	then 
		local x = {};
		x[key] = value 
		local json = sjson.encode(x)
		local t = topic..key
		--local json = '{"'.. key .. ':",' .. value ..'}'
		if dbg then p_line(60,_,"MQTT Publish: "..t); print(json) end
		mq:publish(t,json,0,0,function(client) if dbg then print("MQTT Publish:","\t\tdata received") end end)
	else print("Error C.cmd is not a string")
	end
end  


function pins_msg(T,w)  
    local X={}
    for k = 0, D.pins - 1  do
        local m = T[k].m
        if w and (m == gpio.OUTPUT or m == gpio.OPENDRAIN) then
            if dbg then print(string.format("Write: p[%s] =%s",k, T[k].w)) end
            X[tostring(k)]=T[k].w
        elseif not w and (m == gpio.INPUT or m == gpio.INT)then
            if dbg then print(string.format("Read: p[%s] =%s",k, T[k].r)) end
            X[tostring(k)]=T[k].r
        end
    end
    return X
end

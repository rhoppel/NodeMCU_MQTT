local fn,fp = "commands", {"0.7h","5/31/18","RLH"} if type(fver) == 'table' then fver[fn] = fp end 
if p_local_fver ~= nil then p_local_fver(fn,fp) end

function cmd_process(C)
	if type(C.cmd) == 'string' then 
		if 	   C.cmd == "pins_config" then pins_config(PINS,C.pins)
		elseif C.cmd == "pwm"	then pwm_updt(C.pin)
		elseif C.cmd == "adc"	then  D.adc = adc.read(0); mqtt_pub_smsg(P_TOP.data,'adc',D.adc)
		elseif C.cmd == "uart_write" then uart.write(0,C.uart_write)
		elseif C.cmd == "uart_on"	then uart.on()
		elseif C.cmd == "uart_config" then uart_setup(C.uart_config)
		elseif C.cmd == "heap"	then mqtt_pub_smsg(P_TOP.data,'heap',D.heap)
		elseif C.cmd == "pins"	then mqtt_pub_smsg(P_TOP.data,'pins',PINS)
		elseif C.cmd == "device"	then mqtt_pub_smsg(P_TOP.data,'',{D.ID,D})
		elseif C.cmd == "reset"	then node.reset()
		elseif C.cmd == "pins_write" then pins_write(C.pins)
		elseif C.cmd == "scrn_io"	then scrn_io()
		elseif C.cmd == "DEBUG"	then D.dbg = not D.dbg
		elseif C.cmd == "t_cal"	then D.t_cal = C.t_cal 
		elseif C.cmd == "name"	then D.name = C.name
		elseif C.cmd == "fileOp" then fileOp(C.file)
		elseif C.cmd == "msg" then local x = C.msg 
			if type(x) == 'table' or (type(x) == 'string' and string.len(x) >= 1 ) then D.msg = x; scrn_io('msg')
			else D.msg = nil; scrn_io('status') 
			end
		else
		print(C.cmd, "command not found"); 
		mqtt_pub_error("[commands] \'"..C.cmd.."\' command not implemented")
		end
    end
end

-- commands
function fileOp(U)
	local o, f, O, p = U.op, U.f, U.o, U.p  -- operation, filename, object name, payload
	local T,pl,isJSON = nil,nil,false
	local fnf = "file not found"
	local s = "Success!"
	if f and string.find(f,".json") then isJSON = true end -- test if filename is JSON
	if O then 
		if     O == "MQTT" then T = MQTT
		elseif O == "PINS" then T = PINS
		elseif O == "TMR" then T = TMR
		elseif O == "D" then T = D
		elseif O == "AP" then T = AP
		end
	end

	if     o == "d" and file.exists(f) then file.remove(f); pl = s -- delete file on Device
	elseif o == "d" then pl = fnf
	elseif o == "l" then pl = file.list(); f = "file list" ; isJSON = true -- list files and return value
	elseif o == "ren" then 
		if file.exists(f) then file.rename(f,U.f2) ; pl = s
		else pl = fnf
		end
	elseif o == "r" or o == "w"  or o == "c" then 
			file.open(f,o);
			if o == 'w' then 
				if not p and T then p = sjson.encode(T) end
				file.write(p)
				pl = s
			end
			if o == 'r' or o == 'c' then 
				if file.exists(f) then 
					pl = file.read()
					if o == "c" then 
						file.close()
						file.open(U.f2,"w")
						file.write(pl)
						pl = s
						isJSON = false
					end
					if isJSON then pl = sjson.decode(pl) end-- decode json file
				else pl = fnf
				end
			end
			file.close()

	end
	local msg = {} ; msg.filename = f ; msg.content = pl 
--	print("File Operation Return Object: ", sjson.encode(msg)) 
	if pl  then  mqtt_pub_smsg(P_TOP.data,'files',msg) end
	
end

-- alternate between the possible OLED screen modes 
function  scrn_io(s) 
	tmr_rst('scrn') 
	local z = D.screen
	if s == 'cycle' or s == 'pins' or s == 'status' or s == 'msg' then print(z); z = s
	elseif z == 'cycle' then z = 'pins' ; tmr_rst('scrn', TMR.scrn.tio)
	elseif z == 'pins' then z = 'status'
	elseif D.msg and z == 'status' then z = 'msg'
	else   z = 'cycle'
	end
	D.screen = z
	screens() -- update screen displays
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
		i = tonumber(k)
		if T[i].m ~= nil or (U[k] and U[k].m ~= nil)              -- only process additional info if mode is specified
		then 
			--T[i] = {}			-- clear previous pin state
			T[i] = T[i] or {}
			T[i].m = U[k].m	or T[i].m -- m (mode) {"","OUTPUT(1)","OPENDRAIN(3)","INPUT(0)","INT(2)"}
			if U[k].pu ~= nil then T[i].pu = U[k].pu end	-- p (pullup type) {("PULLUP(1)"), (FLOAT(0))(default)}
			if U[k].n  ~= nil then T[i].n  = U[k].n end
			if T[i].m == gpio.INPUT or T[i].m == gpio.INT 
			then 
				T[i].r = 0   -- r (read state) {"0","1"}
				if U[k].t ~= nil then T[i].t = U[k].t end	-- t (trigger type) {"up", "down", "both", "low", "high"}
			else 
				if U[k].w    ~= nil then T[i].w    = U[k].w end	-- w (write) {"LOW","HIGH"} 
				if U[k].pwm  ~= nil then T[i].pwm  = U[k].pwm end -- pwm modulation on/off
				if U[k].freq ~= nil then T[i].freq = U[k].freq end -- pwm frequency (0 - 1000 Hz)
				if U[k].duty ~= nil then T[i].duty = U[k].duty end -- duty cycle (0-1024)
				--if T[i].pwm ~= nil then pwm_updt(k) end
			end
		else
				mqtt_pub_error("[commands] pin:"..k.." mode is not specified")		
		end
	end

end  
--  publish (MQTT) a simple JSON encoded message
function mqtt_pub_smsg(topic,key,value,noEnc)
	nE = noEnc or nil -- flag to prevent JSON encodeingof payload
	if type(key)  == 'string' 	
	then 
		local x = {};
		x[key] = value 
		if key == '' then x = value end
		local json
		if nE then json = x
		else json = sjson.encode(x)
		end
		local t = topic..key
		--local json = '{"'.. key .. ':",' .. value ..'}'
		if D.dbg then p_line(60,_,"MQTT Publish: "..t); print(json) end
		mq:publish(t,json,0,0,function(client) if D.dbg then print("MQTT Publish:","\t\tdata received") end end)
	else print("Error C.cmd is not a string")
	end
end  

function mqtt_pub_error(msg)
	mqtt_pub_smsg("error","error",msg)
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


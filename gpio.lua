 local fn,fp = "gpio", {"0.6a","2/1/18","RLH"} if type(fver) == 'table' then fver[fn] = fp end 
if p_local_fver ~= nil then p_local_fver(fn,fp) end
 
local updt_r = updt_r or 230  -- gpio update
local tmr_r = tmr_r or '5'    -- read gpio tim
local PINS = PINS or {}


 -- hardware functions
function pins_mode(T)
	for i = 0, D.pins - 1 do
		if T[i].m
		then
--		print("Mode", i,T[i].m)
			if T[i].pu then
--				print(i, 'gpio.'.. T[i].m, gpio.PULLUP)
				gpio.mode(i, T[i].m, gpio.PULLUP )
			else
--				print(i, 'gpio.'.. T[i--].m)
				gpio.mode(i, T[i].m)
			end
		end
		if T[i].pwm ~= nil then
			pwm.setup(i,T[i].freq,T[i].duty)
			-- if T[i].pwm then pwm.start(i) end
		end 
	end
end

pins_mode(PINS)
pins_mode = nil -- remove after using

---[[
function pins_rw()
	local T = PINS
	local r_chng = false
	for i = 0,D.pins - 1 do
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
		if dbg then p_line(_,_,"INPUTs have changed") end
		--if D.mqtt ~= 'userdata' then print("INPUT changed but MQ not defined yet") end
		--if D.mqtt then mq:publish(P_TOP.data, sjson.encode({["data"] = 'ipins', ["ipins"] = pins_msg(PINS)}),0,0) end
		if D.mqtt then mqtt_pub_smsg(P_TOP.data, "ipins", pins_msg(PINS))
		else print("ERROR: MQTT not connected")
		end
	end
    return r_chng
end 
--]]


---[[
 function pwm_updt(i)
	local T = PINS
	if T[i].pwm == nil then return end
	pwm.setup(i,T[i].freq,T[i].duty)
	if T[i].pwm then pwm.start(i) end
 end
 --]]

TMR.rp.f = pins_rw
--tmr_rst('rp')

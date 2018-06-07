function pins_config(T,U)  -- PIN CONSTRUCTOR
	for k,v in pairs(U) do
		local i = tonumber(k)
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
				if U[k].freq ~= nil then T[i].freq = U[k].freq end -- pwm frequency (0 - 1000 Hz)
				if U[k].duty ~= nil then T[i].duty = U[k].duty end -- duty cycle (0-1024)
				if U[k].pwm  ~= nil then T[i].pwm  = U[k].pwm ; pwmG(PINS,i,nil) end -- pwm modulation on/off
				--if T[i].pwm ~= nil then pwm_updt(k) end
			end
		else
				mqtt_pub_error("[commands] pin:"..k.." mode is not specified")		
		end
	end
end 

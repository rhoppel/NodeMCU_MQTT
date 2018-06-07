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
pins_mode = nil

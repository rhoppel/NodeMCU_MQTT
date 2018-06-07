for i = 0,D.pins-1 do
T = PINS
	print(string.format("%s[%s] \t= mode: %s\twrite: %s\tread: %s pu:%s", 
xname or "PINS", i, T[i].m or "", T[i].w or "", T[i].r or "", tostring(T[i].pu) or ""))
	if T[i].pwm ~= nil then 
		print(string.format("\t\tpwm: true\tpwm-freq: %s\tpwm-duty: %s", 
		T[i].freq or "", T[i].duty or ""))
	end
end

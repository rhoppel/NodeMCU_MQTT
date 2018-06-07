function fileOp(U)
	local fnf = "file not found"
	local s = "Success!"
	local o, f, O, p = U.op, U.f, U.o, U.p  -- operation, filename, object name, payload
	local T,pl,isJSON = nil,fnf,false

	if f and string.find(f,".json") then isJSON = true end -- test if filename is JSON
	if O then 
		if     O == "MQTT" then T = MQTT
		elseif O == "PINS" then T = PINS
		elseif O == "TMR" then T = TMR
		elseif O == "D" then T = D
		elseif O == "AP" then T = AP
		elseif O == "M" then T = M
		end
	end

	if     o == "d" and file.exists(f) then file.remove(f); pl = s -- delete file on Device
	elseif o == "l" then pl = file.list(); f = "file list" ; isJSON = true -- list files and return value
	elseif o == "ren" then 
		if file.exists(f) then file.rename(f,U.f2) ; pl = s end
	elseif o == "r" or o == "w"  or o == "c" then 
			file.open(f,o);
			if o == 'w' then 
				if not p and T then p = sjson.encode(T) end
				--print("fileOp:", "p:",p)
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
				end
			end
			file.close()

	end
	local msg = {} ; msg.filename = f ; msg.content = pl 
--	print("File Operation Return Object: ", sjson.encode(msg)) 
	if pl  then  mqtt_pub_smsg(P_TOP.data,'files',msg) end
	
end

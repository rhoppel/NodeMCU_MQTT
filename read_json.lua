-- read a json file and override system object
function  oo(fn)
	print("processing: ", fn, type(U))
	if file.exists(fn) then
    	file.open(fn,"r")
		local T = sjson.decode(file.read())
		file.close()
		print("Read JSON  result: ", type(T))
		print("FINAL: ",fn, sjson.encode(T))
    	return T
    else
		print ("ERROR: ",fn," file does not exist")
		return nil
    end

end

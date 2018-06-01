-- read a json file and override system object
function  oo(U,fn,array)
    local i
        print("processing: ", fn, type(U))
        if file.exists(fn) then
                local T={}
                file.open(fn,"r")
                T = sjson.decode(file.read())
                file.close()
                print(x)
                print("ORIG:  ",fn, sjson.encode(U))
                for k,v in pairs(T) do
                        if array then i = tonumber(k) 
                        else i = k
                        end -- index by integer if array
                        U[i] = v
                end
        else
                print ("ERROR: ",fn," file does not exist")
        end
    print("FINAL: ",fn, sjson.encode(U))
end
--[[
oo(MQTT,"MQTT.json")
oo(AP,"AP.json")
oo(D,"D.json")
oo(PINS,"PINS.json",true)
oo(TMR,"TMR.json",true)

oo = nil
--]]

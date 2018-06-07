local Sp,Si,Sm = "personality.lua","init.lua", "main.lc"
local SA,SR,SL,SC,SM,SH,SW = "Aborting: ","Running: ", "Loading: ", "Connected: " , " Missing", "Heap: ","Waiting... "
print(SH, node.heap())
fver = {} ; OS = false ; print(SL,SH,node.heap()) -- hardware init.lua means NO OS
local fn,fp = "init", {"0.4b","5/23/18","RLH"} ; fver[fn] = fp
print(string.format("Load: %s.lua  Ver:%s %s %s \n" ,fn, fp[1], fp[2], fp[3]))


-- load credentials, 'SSID' and 'PASSWORD' declared and initialize in there
if file.exists(Sp) then dofile(Sp) end
-- strings
--[[
nh = node.heap
m = "main"

p = print
d = dofile
fe = file.exists
sS = "Success!"
-- s used in OLED.lua
sR = "Running"
sE = "ERROR"
--]]

function startup()
    if file.open(Si) == nil then
        print(Si,SM)
    else
        print(SR)
        file.close(Si)
        if file.exists(Sm) then print(SL,Sm) dofile(Sm)
        else print(Sm, SM)
        end
    end
end

-- Define WiFi station event callbacks 
wf_cnct = function(T) 
  print ("\n")
  print(SC,T.SSID)
  print(SW, " for IP address...")
  print(SH, node.heap())
  if dc ~= nil then dc = nil end  
end

wf_gotip = function(T) 
  -- Note: Having an IP address does not mean there is internet access!
  -- Internet connectivity can be determined with net.dns.resolve().    
  print("Wifi connection is ready! IP address is: "..T.IP)
  print("Startup will resume momentarily, you have 3 seconds to abort.")
  print(SW) 
  tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)
  print("Check Internet connectivity")
  net.dns.resolve(WEB_CHECK, function(sk, ip)     
    if (ip == nil) then print("DNS fail!") 
      else print(ip) 
      end 
    end)
end

wf_dscnt = function(T)
  if T.reason == wifi.eventmon.reason.ASSOC_LEAVE then 
    --the station has disassociated from a previously connected AP
    return 
  end
  --tries: how many times the station will attempt to connect to the AP. Should consider AP reboot duration.
  local total_tries = 75
  print("\nWiFi connection to AP("..T.SSID..") has failed!")

  --There are many possible disconnect reasons, the following iterates through 
  --the list and returns the string corresponding to the disconnect reason.
  for key,val in pairs(wifi.eventmon.reason) do
    if val == T.reason then
      print("Disconnect reason: "..val.."("..key..")")
      break
    end
  end

  if dc == nil then 
    dc = 1 
  else
    dc = dc + 1 
  end
  if dc < total_tries then 
    print("Retrying ("..(dc+1).." of "..total_tries..")")
  else
    wifi.sta.disconnect()
    print(SA)
    dc = nil  
  end
end

-- Register WiFi Station event callbacks
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, wf_cnct)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, wf_gotip)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, wf_dscnt)

print(SC)
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=AP.SSID, pwd=AP.PASSWORD})
-- wifi.sta.connect() not necessary because config() uses auto-connect=true by default


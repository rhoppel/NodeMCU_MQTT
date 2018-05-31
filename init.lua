print("Initial heap:", node.heap())
fver = {} ; OS = false ; print("init.lua:(heap)",node.heap()) -- hardware init.lua means NO OS
local fn,fp = "init", {"0.4b","5/23/18","RLH"} ; fver[fn] = fp
print(string.format("Load: %s.lua  Ver:%s %s %s \n" ,fn, fp[1], fp[2], fp[3]))

-- load credentials, 'SSID' and 'PASSWORD' declared and initialize in there
dofile("personality.lua")

function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Running")
        file.close("init.lua")
        if file.exists("test.lua") then dofile("test.lua")
        elseif file.exists("main.lc") then print"Loading: main.lc" dofile("main.lc")
        elseif file.exists("main.lua") then dofile("main.lua") 
        end
    end
end

-- Define WiFi station event callbacks 
wifi_cnct_event = function(T) 
  print ("\n")
  print("Connection to AP("..T.SSID..") established!")
  print("Waiting for IP address...")
  print("heap: ", node.heap())
  if dscnct_ct ~= nil then dscnct_ct = nil end  
end

wifi_got_ip_event = function(T) 
  -- Note: Having an IP address does not mean there is internet access!
  -- Internet connectivity can be determined with net.dns.resolve().    
  print("Wifi connection is ready! IP address is: "..T.IP)
  print("Startup will resume momentarily, you have 3 seconds to abort.")
  print("Waiting...") 
  tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)
  print("Check Internet connectivity")
  net.dns.resolve(WEB_CHECK, function(sk, ip)     
    if (ip == nil) then print("DNS fail!") 
      else print(ip) 
      end 
    end)
end

wifi_dscnct_event = function(T)
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

  if dscnct_ct == nil then 
    dscnct_ct = 1 
  else
    dscnct_ct = dscnct_ct + 1 
  end
  if dscnct_ct < total_tries then 
    print("Retrying connection...(attempt "..(dscnct_ct+1).." of "..total_tries..")")
  else
    wifi.sta.disconnect()
    print("Aborting connection to AP!")
    dscnct_ct = nil  
  end
end

-- Register WiFi Station event callbacks
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, wifi_cnct_event)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, wifi_got_ip_event)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, wifi_dscnct_event)

print("Connecting to WiFi access point...")
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=AP.SSID, pwd=AP.PASSWORD})
-- wifi.sta.connect() not necessary because config() uses auto-connect=true by default


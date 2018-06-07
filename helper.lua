local fn,fp = "helper", {"0.5a","1/21/18","RLH"} if type(fver) == 'table' then fver[fn] = fp end 
p_local_fver(fn,fp)

-- make id a concatenation of devide and last 6 digits of MAC address
-- function make_id() return D.type .."_".. string.sub(string.gsub(wifi.sta.getmac(), ":", ""),7,12) end

--D.ID = make_id()
--make_id =  nil

function tmr_rst(z,time) tmr.alarm(TMR[z].n, time or TMR[z].t, 1, TMR[z].f) end

function dump(o,x)          -- dumps the table to stdio
   if type(o) == 'table' then
      local x = x or "\n"         -- insert a char after each line
      local s = '{'..x
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v,x) .. ','..x
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function tl(T)  -- producen entries in a tabale
    local count =0
    for i in pairs(T) do count = count + 1 end
    return count
end

function pairsByKeys (T, f) -- contructs a sorted array from keys in a table
    local a = {}
    for n in pairs(T) do   -- create a list with all keys
        a[#a + 1] = n
    end
    table.sort(a, f)       -- sort the list
    local i = 0            -- iterator variable
    return function ()     -- iterator function
        i = i + 1
        return a[i], T[a[i]]   -- return key, value
    end    
end

function g_dinfo()
    local X = {}
    for k, v in pairs(D) do X[k] = v end
    X.heap = node.heap()
    X.chipid =node.chipid()
    X.flashsize = node.flashsize()
    X.flashid = node.flashid()
    X.sta_mac = wifi.sta.getmac()
    X.ap_mac	=wifi.ap.getmac()
    X.ip = g_wifi(ap).ip
    local z,y = node.bootreason()
    X.bootreason_extnd = y
    return X
end 

function g_wifi(config)  -- updatea WiFi station (STA) or optionally AP parameters
    local ip, mask, gateway, ap_mac, sta_mac
    if config == 'ap' then 
        ip, mask, gateway =wifi.ap.getip() 
        ap_mac =wifi.ap.getmac()
    else
        ip, mask, gateway = wifi.sta.getip()
        sta_mac = wifi.sta.getmac()
    end

    return {
    ip = ip or '?',
    mask = mask or '?',
    gateway = gateway or '?',
    ssid = AP.SSID,
    password = AP.PASSWORD,
    ap_mac = ap_mac,
    sta_mac = sta_mac,
    }
end

function p_sort_keys(t,l)   -- prints a sorted table by keys
    l = l or ""             -- l = optional label
    p_line(nil , "-" , l)
    for name, line in pairsByKeys(t) do
        if type(name) ~= 'table' and type(line) ~= 'table' then
        print(string.format("%-22s%+7s", name, line))
        --print(string.format( "%-10q%s%s", name, make_tab(""), line))
        end
    end 
    --p_line(40 , "*")
end

function p_fsize() p_sort_keys(g_file_list(),"File Sizes ") end

function p_dinfo() print(dump(g_dinfo())) end

function p_fver()           -- prints registered files and sizes
    --print(dump(fver))
    p_line(_,_,"File Versions")
    for k,v in pairs(fver) do
        local name = k --".. .lua"
        print(string.format("%-20sVer: %-s \t%s \tAuthor:%s",name,fver[k][1],fver[k][2],fver[k][3]))
    end
end

function p_pins(T,xname)
    for i = 0,D.pins-1 do
        print(string.format("%s[%s] \t= mode: %s\twrite: %s\tread: %s pu:%s name:%s" , 
        xname or "PINS", i, T[i].m or "", T[i].w or "", T[i].r or "", tostring(T[i].pu) or "",T[i].n or ""))
        if T[i].pwm ~= nil then 
         print(string.format("\t\tpwm: true\tpwm-freq: %s\tpwm-duty: %s", 
         T[i].freq or "", T[i].duty or ""))
        end
    end
end

function p_G() -- print globals
    for k,v in pairs(_G) do print(k,v) end
end

-- print STATUS and Tables
function p_status()
    p_line(nil,nil,"MQTT_SERVER ")
    print(dump(MQTT_SERVER))
    p_line(nil,nil,"S_TOPICS ")
    print(dump(S_TOPICS))
    p_line(nil,nil,"P_TOPICS ")
    print(dump(P_TOPICS))
    p_line(nil,nil,"PINS ")
    print(dump(PINS,""))
    print("Number of GPIO Pins: ",D.pins)
    p_line(nil,nil,"AP ")
    print(dump(g_wifi('ap')))
    p_line(nil,nil,"STA ")
    print(dump(g_wifi('ap')))
    p_line(nil,nil,"D_INFO ")
    p_dinfo()
    p_fsize()
    p_fver(fver)
end

function init_clean()
    p_status = nil
    p_fver = nil
    tl = nil
    p_sort_keys = nil
    pairsByKeys = nil
    init_clean = nil
    startup = nil
end

function init_clean2()
    p_local_fver = nil
    p_pins = nil
    dump = nil
    p_fsize = nil
    p_dinfo = nil
    g_dinfo = nil
    fver = nil
    init_clean2 = nil
end


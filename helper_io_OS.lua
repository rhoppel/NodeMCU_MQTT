local fn,fp = "helper_io_OS", {"0.4","1/12/18","RLH"} if type(fver) == 'table' then fver[fn] = fp end 
p_local_fver(fn,fp)

-- functions tied to hardware but modified to work on OS
--function make_id() return D.type .."_".. string.gsub(g_sta_mac(), ":", "") end

function id() return make_id() end

function p_line(b,c,x)  -- prints a line to the output
    b = b or 60         -- number of chars to print
    c = c or "-"        -- char to print
    x = x or ""         -- label at beginning of line
    for i = 1, b - #x do
        x = x .. c
    end
    print(x)
end

function g_file_list()
	local T = {}
	T["dummy_list"] = 123
	T["config.lua"] = 836
	T["helper.lua"] = 2789
	T["main.lua"] = 510
	T["mqtt.lua"] = 2228
	T["mqtt_callback.lua"] = 1311
	return T
end

function file_exists(fname)  -- only works on OS
    local f=io.open(fname,"r")
    if f~=nil then io.close(f) 
        return true 
    else 
        return false 
    end
end

function g_ap_mac()
	return "01:23:45:67:89:A"
end

function g_sta_mac()
	return "11:22:33:44:55:66"
end

function g_chipid()
	local x = 3333
--	x = 1649453  -- this is the code for a D1Pro
	return x
end

function g_flashsize()
	return 4444
end

function g_flashid()
	return 9999
end

function g_heap() return 12345  end
-- the following returns 3 values
--- ip, mask, gateway = g_wifi_sta()
function g_wifi_sta() 
	return "192.168.000.100", "255.255.0.0", "192.168.100.001"
end

function g_wifi_ap() 
	return "192.168.000.001", "255.255.0.0", "192.168.111.001"
end

--if OS == nil then OS, fver, OSDIR = true, {}, "Z:\\Lua\\MQTT_HL\\" ; print("running on OS") end  -- initialize fver if running on OS
local fn,fp = "main", {"0.5a","6/5/18","RLH"} if type(fver) == 'table' then fver[fn] = fp end 
-- install helper_io 
    -- for OS testing
function p_local_fver(fn,fp)  -- prints filename and version to output
    print(string.format("Load: %s  Ver:%s %s %s" ,fn, fp[1], fp[2], fp[3]))
end
p_local_fver(fn,fp)


function p_line(b,c,x)  -- prints a line to the output
    local i
    b = b or 60         -- number of chars to print
    c = c or "-"        -- char to print
    x = x or ""         -- label at beginning of line
    for i = 1, b - #x do
        x = x .. c
    end
    print(x)
end

--print("heap:",node.heap())

--local FDIR, OS_ext, c_ext, h_ext   = "", "", "lua", "lua"

--if OS then FDIR, OS_ext = OSDIR , "_OS" end
--dofile(FDIR.."helper_io"..OS_ext .. ".lua")
--if  file.exists(FDIR.."config.lc") then c_ext = "lc";print("using config.lc") end 
--if  file.exists(FDIR.."helper.lc") then h_ext = "lc";print("using helper.lc")  end

local modules
--[[if OS
then -- load these modules if testing on OS
    modules = {
    "personality",
    "config",
    "helper",
    "commands",
    --"mqtt_json_test"
    }
--]] 
--else -- modules to load for hardware (config and helper are loaded by init.lua)
    modules = {
--    "personality",
    "config",
    "helper",
    "gpio",
    "commands",
    "read_temp",
    "mqtt_init",
--    "oled_loop"
    --"mqtt_json_test"
    }
--end
heap_load = heap_load or 7000
-- load modules
for i = 1, #modules do
    local fname = modules[i] .. ".lc" -- load compiled code if it exists
    if not  file.exists(fname) then fname = modules[i] .. ".lua" end
    if  file.exists(fname) 
    then
        p_line(_,_,modules[i])
        print(string.format("* Starting %-25s heapsize=%d",fname,node.heap()))
        if  node.heap() < heap_load then 
            if init_clean() then init_clean() end
            print("heap size too small...cleaning:",node.heap())
        end
        dofile(fname) 
        collectgarbage('collect')
        collectgarbage('collect')
        print(string.format("* Completed %-25s heapsize=%d",fname,node.heap()))
    else
        print(fname .. " does not exist")
    end
--    p_line()
end

-- close un-used variables after initialization
modules = nil
--FDIR, OS_ext, OS, OSDIR, c_ext, h_ext   = nil, nil, nil, nil, nil, nil
sdl, sda, ow_pin = nil, nil, nil
WEB_CHECK = nil
heap_load = nil

--tupdt, supdt = nil, nil 
p_line(_,_,'Device Info')
p_dinfo()
p_line(_,_,'PINS configuration')
p_pins(PINS,'PINS')
p_line()

if p_fver then  p_fver() ; p_line() end

--if p_status then p_line(_,_,'status'); p_status() end
if init_clean then init_clean() ; p_line(_,_,"init_clean()") end
tmr.alarm(TMR.dly.n, 4000, tmr.ALARM_SINGLE, function() 
	init_clean2() 
	p_line(_,_,"Clean complete")
	tmr.alarm(TMR.dly.n, 500, tmr.ALARM_SINGLE, 
		function() 
			--MQTT = nil
			AP = nil
			if init_clean2 then init_clean2() end
			p_line(_,_,"start OLED")
            dofile("oled_loop.lc")
            dofile('TMR_init.lua')
            dofile('O_updt.lua')
			dofile('updt_svr.lua')

		end)
	end)

 if  file.exists("main_end.lua") then dofile("main_end.lua") end

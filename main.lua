if OS == nil then OS, fver, OSDIR = true, {}, "Z:\\Lua\\MQTT_HL\\" ; print("running on OS") end  -- initialize fver if running on OS
local fn,fp = "main", {"0.3c","1/11/18","RLH"} if type(fver) == 'table' then fver[fn] = fp end 
-- install helper_io 
    -- for OS testing
function p_local_fver(fn,fp)  -- prints filename and version to output
    print(string.format("Load: %s  Ver:%s %s %s" ,fn, fp[1], fp[2], fp[3]))
end
p_local_fver(fn,fp)
--print("heap:",node.heap())

local FDIR, OS_ext, c_ext, h_ext   = "", "", "lua", "lua"

if OS then FDIR, OS_ext = OSDIR , "_OS" end
dofile(FDIR.."helper_io"..OS_ext .. ".lua")
--if file_exists(FDIR.."config.lc") then c_ext = "lc";print("using config.lc") end 
--if file_exists(FDIR.."helper.lc") then h_ext = "lc";print("using helper.lc")  end

local modules

if OS
then -- load these modules if testing on OS
    modules = {
    "personality",
    "config",
    "helper",
    "commands",
    --"mqtt_json_test"
    } 
else -- modules to load for hardware (config and helper are loaded by init.lua)
    modules = {
--    "personality",
    "config",
    "helper",
    "mqtt_init",
    "gpio",
    "commands",
    "read_temp",
--    "oled_loop"
    --"mqtt_json_test"
    }
end
heap_load = heap_load or 7000
-- load modules
for i = 1, #modules do
    local fname = FDIR..modules[i] .. ".lc" -- load compiled code if it exists
    if not file_exists(fname) then fname = FDIR..modules[i] .. ".lua" end
    if file_exists(fname) 
    then
        p_line(_,_,modules[i])
        print(string.format("* Starting %-25s heapsize=%d",fname,g_heap()))
        if  g_heap() < heap_load then 
            if init_clean() then init_clean() end
            print("heap size too small...cleaning:",g_heap())
        end
        dofile(fname) 
        print(string.format("* Completed %-25s heapsize=%d",fname,g_heap()))
    else
        print(fname .. " does not exist")
    end
--    p_line()
end

-- close un-used variables after initialization
modules = nil
FDIR, OS_ext, OS, OSDIR, c_ext, h_ext   = nil, nil, nil, nil, nil, nil
sdl, sda, ow_pin = nil, nil, nil
WEB_CHECK = nil
heap_load = nil

--tupdt, supdt = nil, nil 
p_line(_,_,'Device Info')
p_dinfo()
p_line(_,_,'PINS configuration')
p_pins(PINS,'PINS')
p_line()

 if file_exists("main_end.lua") then dofile("main_end.lua") end

local fn,fp = "helper_io", {"0.3","1/5/18","RLH"} ;fver[fn] = fp ; --p_local_fver(fn,fp)
--local fn,fp = "helper_io", {"0.1","1/1/18","RLH"} if type(fver) == 'table' then fver[fn] = fp end 
--[[
function p_line(b,c,x)  -- prints a line to the output
    b = b or 60         -- number of chars to print
    c = c or "-"        -- char to print
    x = x or ""         -- label at beginning of line
    for i = 1, b - #x do
        x = x .. c
    end
    print(x)
end
--]]
p_line(_,_,"helper_io")
p_local_fver(fn,fp) ;print("helper_io:heap",node.heap())

function make_id() return D.type .."_".. string.gsub(g_sta_mac(), ":", "") end

function g_file_list()  return file.list() end

function file_exists(fname)  return file.exists(fname) end

function g_sta_mac() return wifi.sta.getmac() or "01:23:45:67:89:A" end 

function g_ap_mac() return wifi.ap.getmac() or "11:22:33:44:55:66" end

function g_heap() return node.heap() or "11:22:33:44:55:66" end

function g_chipid() return node.chipid() or "11:22:33:44:55:66" end

function g_flashsize() return node.flashsize() or "77776" end

function g_flashid() return node.flashid() or "9999" end
-- the following returns 3 values
function g_wifi_sta() local ip, mask, gateway = wifi.sta.getip() return ip, mask, gateway end

function g_wifi_ap() local ip, mask, gateway = wifi.ap.getip() return ip, mask, gateway end

function tmr_rst(z,time) tmr.alarm(TMR[z].n, time or TMR[z].t, 1, TMR[z].f) end

local fn,fp = "read_temp", {"0.4a","4/6/18","RLH"} if type(fver) == 'table' then fver[fn] = fp end 
p_local_fver(fn,fp)

local ow_pin = ow_pin or '2'      -- GPIO pin to

ds18b20.setup(tonumber(ow_pin))

function get_temp()
    return ds18b20.read( function(ind,rom,res,temp,tdec,par)
        --print(ind,string.format("%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X",string.match(rom,"(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)")),res,temp,tdec,par)
        --print(string.format("myTemp:%s.%s C",temp,tdec))
        local x = D.tmpr
        D.tmpr =((temp * 1000 * 9 /5 + 32000)  + (tdec * 9 /5) + 500)/1000 + D.t_cal
        local y = D.heap
        D.heap = node.heap()
        --ftemp2 = tdec * 9 /5 
        --ftemp = (ftemp1 + ftemp2 + 500) / 1000
        if D.dbg then print(string.format("T:%sF %s.%sC Cal:%s heap: %s",D.tmpr,temp,tdec,D.t_cal, D.heap)) end
        if x ~= D.tmpr or D.dbg then mqtt_pub_smsg(P_TOP.data,"tmpr",D.tmpr) end -- send data if temperature has changed
        if y ~= D.heap or D.dbg then mqtt_pub_smsg(P_TOP.data,"heap",D.heap) end
        return D.tmpr
    end,{});
end

TMR.tmpr.f = get_temp -- store function call
-- tmr_rst('tmpr')


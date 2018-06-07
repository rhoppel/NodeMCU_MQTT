local fn,fp = "config", {"0.9e","6/5/18","RLH"} if type(fver) == 'table' then fver[fn] = fp end 
if p_local_fver == nil then dofile("p_local_fver.lua") end
p_local_fver(fn,fp) --;print("config:(heap)",node.heap())

local fn = "read_json.lua"
if file.exists(fn) then dofile(fn) end

NODEMCU = {}
NODEMCU[1] = {"D1P",11,4}
NODEMCU[2] = {"D1",9,4}
NODEMCU[3] = {"D1m",9,4}
NODEMCU[4] = {"TS",20,4}

local m = 3
--if not file.exists("D.json") then
D = oo("D.json", false)
if not D then
D =  {
["name"] = name or "?",
["type"] = NODEMCU[m][1] or NM,
["pins"] = NODEMCU[m][2], --
["LED"] = NODEMCU[m][3],  -- pin that controls LED
["ID"] = NODEMCU[m][1] .."_".. string.sub(string.gsub(wifi.sta.getmac(), ":", ""),7,12),
["t"]  = 0,      -- last temperature sample
["heap_min"] = heap_min or 4000 ,-- minimum heapsize before processing MQTT packet to prevent overflow
["t_cal"] = t_cal or 0,
["screen"] = screen or 'cycle',  -- video mode /  true means IO screen only
["mqtt"] = false,        -- state of the MQTT connection
["dbg"] = dbg or false,        -- is the DEBUG state active?
["msg"] = nil,   -- general place for a message to me sent from server 
} 
end
D.mqtt,D.t,D.heap,D.adc = false,0,nil,nil
t_cal, name, screen, heap_min, dbg = nil, nil, nil, nil, nil
NODEMCU = nil -- don't need this afterward

-- set system variables/registers / these may be set in cred.lua
-- timers
TMR = {
["t"] = {["n"] = 3, ["t"] = updt_t or 10101, ["f"] = nil}, -- n(number), t(timer interval), f(function)
["scrn"] = {["n"] = 4, ["t"] = updt_s or 5012,  ["tio"] = updt_sio or 333, ["f"] = nil},
["rp"] = {["n"] = 5, ["t"] = updt_r or 212, ["f"] = nil},
["dly"] = {["n"] = 6, ["t"] = nil},
["heap"] = {["n"] = 0, ["t"] = nil},
}
updt_t, updt_s, updt_r, updt_sio = nil, nil, nil, nil
--TMR = oo(TMR,"TMR.json",true)

-- Configure GPIO PIN States
sdl = sdl or '1'       -- OLED
sda = sda or '2'       -- OLED 
sla = sla or 0x3c    -- OLED
ow_pin = ow_pin or '2'    -- temperature sensor


PINS_CONFIG = PINS_CONFIG or {
[0] = {["m"] = nil},   -- (UNAVAILABLE) commenting this out produces the same result
[1] = {["m"] = nil},   -- (UNAVAILABLE)  I2C SD1 / OLED 
[2] = {["m"] = nil} ,  -- (UNAVAILABLE)  I2C SDL / OLED
[3] = {["m"] = nil} ,  --  
[4] = {["m"] = nil},   -- set inital write state
[5] = {["m"] = nil},   -- set INTerrupt
[5] = {["m"] = nil},   -- set trigger type for interrupt
[6] = {["m"] = nil},   -- set INPUT nmode
[7] = {["m"] = nil},   -- this means the pin mode can be manipualed later 
[8] = {["m"] = nil},   -- UART1 RX / (UNAVAILABLE) unless this in un-commented
[9] = {["m"] = nil},   -- (UNAVAILABLE) unles this in un-commented
[10] ={["m"] = nil},   -- (UNAVAILABLE) unles this in un-commented
}
--]]
--INPUT, OUTPUT, INT, OPENDRAIN, LOW, HIGH, PULLUP = 0, 1, 2, 3, 0, 1, 1
function pins_init(T,U,npins)  -- PIN CONSTRUCTOR
        local i
        for i = 0, npins -1  do  
                T[i] = T[i] or {}  -- a pin with only an empty set means that pin is not available for processing
		if U[i] and  U[i].m              -- only process additional info if mode is specified
		then 
                        T[i].m  = U[i].m	-- m (mode) {"","OUTPUT(1)","OPENDRAIN(3)","INPUT(0)","INT(2)"}
                        if T[i].m == gpio.INPUT then T[i].r  = 0 end  -- r (read state) {"0","1"}
                        if T[i].m == gpio.INT then T[i].r  = 0 end  -- r (read state) {"0","1"}
                        T[i].w    = U[i].w	-- w (write) {"LOW","HIGH"} 
                        T[i].pu   = U[i].pu	-- p (pullup type) {("PULLUP(1)"), (FLOAT(0))(default)}
                        T[i].t    = U[i].t	-- t (trigger type) {"up", "down", "both", "low", "high"}
                        T[i].pwm  = U[i].pwm -- pwm modulation on/off
                        T[i].freq = U[i].freq -- pwm frequency (0 - 1000 Hz)
                        T[i].duty = U[i].duty -- duty cycle (0-1024)		
                end
	end
end  

PINS = {}
pins_init(PINS, PINS_CONFIG,D.pins)
pins_init = nil 
PINS_CONFIG = nil

--if D.pins > 0  then print("> GPIO Pins Initialized") else print("!!! GPIO Pins NOT Initialized")end

-- MQTT Topics
Tpre = Tpre or 'MyTopic'
S_TOP = S_TOP or {
    register =  Tpre.."register",
    cmd =  Tpre,                 -- ID will be added during initialziation
    status =    Tpre.."status",
}

P_TOP = P_TOP or  {
   register =  Tpre.."register",
   data = Tpre,
--    commands =  "/HL/commands",
--    status =    "/HL/status",
}

--oo(MQTT,"MQTT.json")
oo = nil  


local fn,fp = "config", {"0.9b","4/8/18","RLH"} if type(fver) == 'table' then fver[fn] = fp end 
p_local_fver(fn,fp) --;print("config:(heap)",node.heap())

CHIPS = {}
CHIPS[1649453] = {"D1P",11}
CHIPS[494215] = {"D1m",9,4}
CHIPS[3333] = {"TS",20}

D = D or {
["name"] = name or "?",
["type"] = CHIPS[node.chipid()][1] or NM,
["pins"] = CHIPS[node.chipid()][2], --
["LED"] = CHIPS[node.chipid()][3],  -- pin that controls LED
["ID"] = CHIPS[node.chipid()][1] .."_".. string.sub(string.gsub(wifi.sta.getmac(), ":", ""),7,12),
["tmpr"]  = 0,      -- last temperature sample
["heap_min"] = heap_min or 4000 ,-- minimum heapsize before processing MQTT packet to prevent overflow
["t_cal"] = t_cal or 0,
["s_io"] = scrn_io or false,  -- video mode /  true means IO screen only
["mqtt"] = false,        -- state of the MQTT connection
["dbg"] = dbg or false,        -- is the DEBUG state active?
["msg"] = nil,   -- general place for a message to me sent from server 
} 

t_cal, name, scrn_io, heap_min = nil, nil, nil, nil

CHIPS = nil -- don't need this afterwards

-- set system variables/registers / these may be set in cred.lua
-- timers
TMR = TMR or {
["tmpr"] = {["n"] = 3, ["t"] = updt_t or 10101, ["f"] = nil}, -- n(number), t(timer interval), f(function)
["scrn"] = {["n"] = 4, ["t"] = updt_s or 5012,  ["tio"] = updt_sio or 333, ["f"] = nil},
["rp"] = {["n"] = 5, ["t"] = updt_r or 212, ["f"] = nil},
["dly"] = {["n"] = 6, ["t"] = nil},
["heap"] = {["n"] = 0, ["t"] = nil},
}

updt_t, updt_s, updt_r, updt_sio = nil, nil, nil, nil

-- Configure GPIO PIN States
local sdl = sdl or '1'       -- OLED
local sda = sda or '2'       -- OLED 
local sla = sla or 0x3c    -- OLED
local ow_pin = ow_pin or '2'    -- temperature sensor

--[[
ESP8266 GPIO overview
======================
GPIO	Function	State	Restrictions
0	    Boot mode select	3.3V	No Hi-Z
1	    TX0	-	Not usable during Serial transmission
2	    Boot mode select
        TX1	3.3V (boot only)	Don’t connect to ground at boot time 
        Sends debug data at boot time
3	    RX0	-	Not usable during Serial transmission
4	    SDA (I²C)	-	-
5	    SCL (I²C)	-	-
6-11	Flash connection	x	Not usable, and not broken out
12	    MISO (SPI)	-	-
13	    MOSI (SPI)	-	-
14	    SCK (SPI)	-	-
15  	SS (SPI)	0V	Pull-up resistor not usable
16	    Wake up from sleep	-	No pull-up resistor, but pull-down instead 
Should be connected to RST to wake up

D1 MINI
========
PinPin  Function    ESP-8266 Pin
------  --------    ------------
TX      TXD             TXD
RX      RXD             RXD
A0      Analog input,   A0
        max 3.3V input
D0      IO              GPIO16
D1      IO, SCL         GPIO5
D2      IO, SDA         GPIO4
D3      IO,             GPIO0
        10k Pull-up
D4      IO,             GPIO2
        10k pull-up, 
        BUILTIN_LED
D5      IO, SCK         GPIO14
D6      IO, MISO        GPIO12
D7      IO, MOSI        GPIO13
D8      IO,1            GPIO15
        0k pull-down, 
        SS
G       Ground          GND
5V      5V              --
3V3     3.3V            3.3V
RST     Reset           RST
--]]
---[[
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

--if D.pina > 0  then print("> GPIO Pins Initialized") else print("!!! GPIO Pins NOT Initialized")end

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



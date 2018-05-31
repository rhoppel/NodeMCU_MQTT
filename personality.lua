local fn,fp = "personality", {"0.6a","5/25/18","RLH"} ; fver[fn] = fp
print(string.format("Load: %s.lua  Ver:%s %s %s \n" ,fn, fp[1], fp[2], fp[3])) 
AP={
--SSID="HoppelLodge",
SSID="HoppelLodge",
PASSWORD="ThisIsGREEN!"

--PASSWORD="04386051"
}
WEB_CHECK="hoppellodge.com"
Tpre = "/HL/"

MQTT = {
    USER ="rhoppel",
    PWD="maCmah0n",
--    NAME="HS2",
--    IP="192.168.111.250",
--    PORT=1883,
    NAME="hoppellodge.com",
    IP="73.246.28.226",
    PORT=2812,
}

name = "ThingEE 1"  -- friendly name for device
-- OVERRIDE VALUES in main
dbg = false -- debug mode, show status on std output
heap_min = 3000 -- minimum heapsize before processing MQTT packet to prevent overflow
heap_load = 6510 -- delay loading module if heap is < this value
screen = 'cycle'   -- screen mode/ show io pins only
t_cal = -4  -- calibration
updt_t = 30101  -- over-ride temperature update time
updt_s = nil or 5012   -- over-ride screen update time
updt_sio = 710 or 333   -- over-ride IO screen update time
updt_r = 212    -- over-ride read_gpio update time
ow_pin = 2      -- temperature probe pin


---[[
PINS_CONFIG =  {
[0] = {["m"] = gpio.OUTPUT,["w"]  = gpio.LOW },
[1] = {["m"] = nil},     -- (UNAVAILABLE)  I2C SD1 / OLED 
[2] = {["m"] = nil} ,    -- (UNAVAILABLE)  I2C SDL / OLED
[3] = {["m"] = gpio.INPUT,["pu"] = true} ,    --  
[4] = {["m"] = gpio.OUTPUT,["pu"]=false,["w"]=gpio.HIGH,["pwm"]=true,["freq"]=50,["duty"]= 512},
[5] = {["m"] = gpio.INT,["t"] = "down",["pu"] = true},   -- set trigger type for interrupt
[6] = {["m"] = gpio.INPUT,["pu"] = true}, -- set INPUT nmode
[7] = {["m"] = gpio.OUTPUT,["w"]  = gpio.LOW },       -- this means the pin mode can be manipualed later 
[8] = {["m"] = gpio.OUTPUT,["w"]  = gpio.HIGH}, -- UART1 RX / (UNAVAILABLE) unless this in un-commented
[9] = {["m"] = gpio.INPUT,["pu"] = true},   -- (UNAVAILABLE) unles this in un-commented
[10] ={["m"] = nil},  -- (UNAVAILABLE) unles this in un-commented
}
--]]


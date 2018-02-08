------------------------------------------------------------------------------
-- u8glib example which shows how to implement the draw loop without causing
-- timeout issues with the WiFi stack. This is done by drawing one page at
-- a time, allowing the ESP SDK to do its house keeping between the page
-- draws.
--
-- This example assumes you have an SSD1306 display connected to pins 4 and 5
-- using I2C and that the profont22r is compiled into the firmware.
-- Please edit the init_display function to match your setup.
--  
-- Example:
-- dofile("u8g_drawloop.lua")
------------------------------------------------------------------------------
local fn,fp = "oled_loop", {"0.4","1/25/18","RLH"} if type(fver) == 'table' then fver[fn] = fp end 
if p_local_fver ~= nil then p_local_fver(fn,fp) end

---[[ SYSTEM INITIALIZED in MAIN
      --]]
local sda = sda or'2'
local sdl = sdl or '1'
local sla = sla or 0x3c
--local fr_name = D.name or " Thing X"

local disp
local font

s = ""
for i = 0,D.pins - 1 do
local x = i
if i > 9 then x = i -10 end
s = s .. tostring(x)
end

function init_display(sda, sdl, sla)
  i2c.setup(0,tonumber(sda),tonumber(sdl), i2c.SLOW)
  disp = u8g.ssd1306_64x48_i2c(sla)
  font = u8g.font_6x10
end

local function setLargeFont()
  disp:setFont(font)
  disp:setFontRefHeightExtendedText()
  disp:setDefaultForegroundColor()
  disp:setFontPosTop()
end

-- Start the draw loop with the draw implementation in the provided function callback
function updateDisplay(func)
  -- Draws one page and schedules the next page, if there is one
  local function drawPages()
    func()
    if (disp:nextPage() == true) then
      node.task.post(drawPages)
    end
  end
  -- Restart the draw loop and start drawing pages
  disp:firstPage()
  node.task.post(drawPages)
end

function d_fname(l)
  disp:drawFrame(0, l, 64, 15)
  disp:drawStr(5,l+3, D.name)
  if dbg then disp:drawTriangle(58,l,63,l,63,l+5) end 
  if D.s_io then disp:drawTriangle(58,l+14,63,l+14,63,l+9) end
  if D.mqtt then disp:drawTriangle(6,l,0,l,0,l+5) end
end
  
function d_id(l) -- draw id
--  disp:drawFrame(0, l, 64, 15)
  disp:drawLine(0, l+14, 64, l+14)
  disp:drawStr(5,l+3, D.ID)
end

function d_ip(y)
	local ip = wifi.sta.getip()
  disp:drawStr(0,y, string.sub(ip,1,11))
  disp:drawLine(0, y+9, 40, y+9)
    disp:drawLine(40, y+9, 40, y+19)
--	disp:drawStr(41,y+10, string.sub(ip,#ip-3,#ip) )
	disp:drawStr(41,y+10, string.match(string.sub(ip,#ip-3,#ip),'%.%d*%d' ))
end

function d_pins(y)
  for i = 0,D.pins - 1 do 
   if PINS[i].m then --exit if mode is not defined
    local x = i*6
      local m, r, w = PINS[i].m, PINS[i].r, PINS[i].w
      --if m then print(i,m, r,w)  end
      if m == gpio.OUTPUT then
        if w == gpio.LOW 
        then disp:drawFrame(x,y+20, 5, 5)
        elseif w == gpio.HIGH then  disp:drawBox(x,y+20, 5, 5)  end
      elseif m == gpio.OPENDRAIN then 
        if w == gpio.LOW 
        then disp:drawCircle(x+2,y+22, 2)
        elseif w == gpio.HIGH then  disp:drawDisc(x+2,y+22, 2)  end           
      elseif m == gpio.INT then 
        disp:drawStr(x,y-9,PINS[i].t)
        if r == 0 
          then disp:drawCircle(x+2,y+8, 2)
          elseif r == 1 then  disp:drawDisc(x+2,y+8, 2) end
      elseif m == gpio.INPUT then
          if r == 0 
          then disp:drawFrame(x,y+6, 5, 5)
          elseif r == 1 then  disp:drawBox(x,y+6, 5, 5) end
      end 
    end 
  end
end

function d_leg()
  local y = 20
  setLargeFont()
  d_fname(0)
  disp:drawStr(0,34,s)  disp:drawFrame(0,y+2, 5, 5 )
  disp:drawStr(6,y,"-w")
  disp:drawCircle(26,y+4, 2)
  disp:drawStr(32,y,"-r")
  disp:drawLine(0, y+8, 64, y+8)
end

function drawStatus()
  setLargeFont()
  d_fname(0)
  d_id(13)
  d_ip(29)
  disp:drawStr(0,40,D.tmpr)
  disp:drawLine(13, 39, 13, 50)
  --disp:drawFrame(12, 40, 0, 10)
  if D.mqtt then disp:drawStr(16,40,"MQTT") end
end

function drawPins()
  setLargeFont()
  d_fname(0)
  disp:drawStr(0,34,s)
--disp:drawStr(0,34,"12345678901")
--  disp:drawLine(0, 47, 64, 47)
  d_pins(23)
  --disp:drawStr(30,40, "World")
end

drawDemo =  { drawStatus, drawPins }
--drawDemo =  { drawStatus, drawPins, d_leg }


function demoLoop()
  -- Start the draw loop with one of the demo functions
  local f = table.remove(drawDemo,1)  
  if D.s_io then 
     updateDisplay(drawPins)
  else 
    updateDisplay(f)
  end
    table.insert(drawDemo,f)
end

-- Initialise the display
init_display(sda, sdl, sla)
init_display = nil

-- Draw demo page immediately and then schedule an update every 5 seconds.
-- To test your own drawXYZ function, disable the next two lines and call updateDisplay(drawXYZ) instead.

demoLoop()
TMR.scrn.f = demoLoop
--tmr_rst('scrn')


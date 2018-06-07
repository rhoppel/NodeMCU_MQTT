--p_line(_,_,"Load Previous Message if")
dofile('read_json.lua')
local X = oo('PINS.json')
if X then pins_config(PINS,X);dofile("pins_mode.lua") end
X = nil
M = oo("M.json",false)
oo = nil
print("M(type): ",type(M))
if M then D.screen = 'msg' ; screens() end

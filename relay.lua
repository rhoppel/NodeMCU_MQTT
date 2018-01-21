gpio.mode(1, gpio.OUTPUT)
function r_on () gpio.write(1,gpio.HIGH) end
function r_off () gpio.write(1,gpio.LOW) end
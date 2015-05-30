
local moduleName = "Led"
local M = {}
_G[moduleName] = M

local led_pin = 4

function M.set_color(color)

	if color == nil then
		color = { 0, 0, 0 }
		print("invalid color, disabling LED")
	end

	ws2812.writergb(led_pin, string.char(color[1], color[2], color[3]))
end

function M.blink(id, color1, color2, interval)
	tmr.alarm(id, interval, 1, function()
		if toggle == 0 then
			toggle = 1
			set_color(color1)
		else
			toggle = 0
			set_color(color2)
		end
	end)
end

function M.stop(id)
	tmr.stop(id)
end

led_pin = 4
boot_light_tmr_id = 1

function set_color(color)

	if color == nil then
		color = { 0, 0, 0 }
		print("invalid color, disabling LED")
	end

	ws2812.writergb(led_pin, string.char(color[1], color[2], color[3]))
end

function blink(id, color1, color2, interval)
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

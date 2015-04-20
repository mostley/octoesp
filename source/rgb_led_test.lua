led = 0
tmr.alarm(1, 1000, 1, function()
	if led <= 0 then
		led = led + 1
		print("red")
		ws2812.writergb(4, string.char(255, 0, 0))
	elseif led <= 1 then
       led = led + 1
		print("green")
		ws2812.writergb(4, string.char(0, 255, 0))
	elseif led <= 2 then
        led = led + 1
		print("blue")
		ws2812.writergb(4, string.char(0, 0, 255))
	elseif led <= 3 then
		led = 0
		print("white")
		ws2812.writergb(4, string.char(255, 255, 255))
	end
end)

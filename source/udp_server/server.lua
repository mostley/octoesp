
local moduleName = "Server"
local M = {}
_G[moduleName] = M

PORT = 6803
PIXEL_SIZE = 3
PIXEL_PIN = 4

function M.serve(callback)
	server = net.createServer(net.UDP)
	server:on("receive", function(s, data)
		print(data)
		
		ws2812.writergb(PIXEL_PIN, data)
		--for i = 0,data:len() do
		--	r = string.byte(data, i*PIXEL_SIZE + 0)
		--	g = string.byte(data, i*PIXEL_SIZE + 1)
		--	b = string.byte(data, i*PIXEL_SIZE + 2)
		--	ws2812.writergb(PIXEL_PIN, string.char(r, g, b))
		--end
	end)

	server:listen(PORT)

	callback()
end

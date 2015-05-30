require("led")

local function serverReady()
	print("=== server Ready ===")
	Led.stop(1)
end

local function initServer()
	print("=== init Server ===")
	Led.stop(1)
	Led.blink(1, {0, 0, 0}, {0, 0, 255}, 500)

	require('server')
	Server.serve(serverReady)
end

local function initUpgrade()
	print("=== init Upgrade ===")
	Led.stop(1)
	Led.blink(1, {0, 0, 0}, {255, 0, 0}, 500)

	require('upgrader')
	Upgrader.update(initServer)
end

local function initWifi()
	print("=== init Wifi ===")
	Led.stop(1)
	Led.blink(1, {0, 0, 0}, {0, 255, 0}, 500)

	require('connector')
	Connector.connect(initServer)
end

initWifi()



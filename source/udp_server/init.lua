-- TODO: show state via LED

local function initServer()
	require('server')
	Server.serve()
end

local function initUpgrade()
	require('upgrader')
	Upgrader.update(initServer)
end

local function initWifi()
	require('connector')
	Connector.connect(initUpgrade)
end

initWifi()



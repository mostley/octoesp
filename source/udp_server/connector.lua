
local moduleName = ...
local M = {}
_G[moduleName] = M

local wifi_timer = 3
local wifi_check_interval = 1000
local wifi_init_callback = nil
local web_server = nil

function try_connect()
	if wifi.sta.status() == 5 then
		tmr.stop(wifi_timer)
		ip = wifi.sta.getip()
		print(ip)

		wifi_init_callback()
	else
	    wifi.setmode(wifi.STATION)
	    wifi.sta.config("SSID","password")
	end
end

function set_ap()
	cfg = {}
	cfg.ssid = "ESP UDP Server"
	cfg.pwd = ""
	wifi.ap.config(cfg)

	web_server = net.createServer(net.TCP)
    web_server:listen(80, function(conn)
      conn:on("receive", function(conn, payload)
      	print(payload)
      	-- TODO find out if post and save data
        conn:send('<h1>Welcome to the OctoESP Configurator.</h1><br/><label for="ssid">SSID:</label><form name="ssid" method="POST" action="/"><br/><label for="password">Password:</label><input name="password" type="text" value=""/><input type="password" value=""/>')
      end)
      conn:on("sent",function(conn) conn:close() end)
    end)
end

function M.connect(callback)
	wifi_init_callback = callback
	tmr.alarm(wifi_timer, wifi_check_interval, 1, try_connect)
end
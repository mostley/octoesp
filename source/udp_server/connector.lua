
local moduleName = "Connector"
local M = {}
_G[moduleName] = M

local wifi_timer = 3
local wifi_check_interval = 1000
local wifi_init_callback = nil
local web_server = nil
local wifi_credentials = { { ["ssid"] = "matrix", ["password"] = "51whc3xt"}, { ["ssid"] = "Fablab Karlsruhe", ["password"] = "foobar42"} }
local wifi_credential_counter = 0
local wifi_current_ssid = ""

function try_connect()
	if wifi.sta.status() == 5 then
		tmr.stop(wifi_timer)
		ip = wifi.sta.getip()
		print("successfully connected to " .. wifi_current_ssid + " (" .. ip .. ")")

		wifi_init_callback()
	else
		if wifi_credential_counter > table.getn(wifi_credentials) then
			wifi_credential_counter = 0
			
			print("all known credentials failed, starting AP")
			tmr.stop(wifi_timer)
			set_ap()
		end

	    wifi.setmode(wifi.STATION)
	    credentials = wifi_credentials[wifi_credential_counter]

		print("trying to connect to " .. credentials["ssid"] .. ":" .. credentials["password"])
	    wifi.sta.config(credentials["ssid"], credentials["password"])
	    wifi_current_ssid = credentials["ssid"]
	    wifi_credential_counter += 1
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
      	-- TODO find out if post and add credentials to start of table
        conn:send('<h1>Welcome to the OctoESP Configurator.</h1><br/><label for="ssid">SSID:</label><form name="ssid" method="POST" action="/"><br/><label for="password">Password:</label><input name="password" type="text" value=""/><input type="password" value=""/>')

		if false then -- if post & payload available
			tmr.alarm(wifi_timer, wifi_check_interval, 1, try_connect)
		end        
      end)
      conn:on("sent",function(conn) conn:close() end)
    end)

    print ("AP running Webserver started, waiting for credentials")
end

function M.connect(callback)
	wifi_init_callback = callback
	tmr.alarm(wifi_timer, wifi_check_interval, 1, try_connect)
end
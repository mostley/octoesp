local moduleName = "Connector"
local M = {}
_G[moduleName] = M

require('accesspoint')

local wifi_timer = 3
local wifi_check_interval = 1000
local wifi_init_callback = nil
local web_server = nil
local wifi_credentials = { { ["ssid"] = "matrix", ["password"] = "51whc3xt" } }
local wifi_credential_counter = 0
local wifi_current_ssid = ""

local function try_connect()
	print("try_connect")
	print(wifi.sta.status())
	if wifi.sta.status() == 5 then
		tmr.stop(wifi_timer)
		ip = wifi.sta.getip()
		print("successfully connected to " .. wifi_current_ssid .. " (" .. ip .. ")")

		wifi_init_callback()
	else
		credential_count = table.getn(wifi_credentials)
		if wifi_credential_counter > credential_count or credential_count == 0 then
			wifi_credential_counter = 0
			
			print("all known credentials failed, starting AP")
			tmr.stop(wifi_timer)
			
			AccessPoint.startAP(function(ssid, pwd) 
				credentials.insert({ ["ssid"] = ssid, ["password"] = pwd })

				tmr.alarm(wifi_timer, wifi_check_interval, 1, try_connect)
			end)
		else
		    wifi.setmode(wifi.STATION)
		    credentials = wifi_credentials[wifi_credential_counter]

			print("trying to connect to " .. credentials["ssid"] .. ":" .. credentials["password"])
		    wifi.sta.config(credentials["ssid"], credentials["password"])
		    wifi_current_ssid = credentials["ssid"]
		    wifi_credential_counter = wifi_credential_counter + 1
		end
	end
end

function M.connect(callback)
	wifi_init_callback = callback
	tmr.alarm(wifi_timer, wifi_check_interval, 1, try_connect)
end

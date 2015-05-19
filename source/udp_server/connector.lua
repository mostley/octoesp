
local moduleName = ...
local M = {}
_G[moduleName] = M

local wifi_timer = 3
local wifi_check_interval = 1000
local wifi_init_callback = nil

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
end

function M.connect(callback)
	wifi_init_callback = callback
	tmr.alarm(wifi_timer, wifi_check_interval, 1, try_connect)
end
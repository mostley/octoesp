--ssid = "Fablab Karlsruhe"
--password = "foobar42"
ssid = "matrix"
password = "51whc3xt"

function init_wifi()

	print("init wifi")

	wifi.setmode(wifi.STATION)
	wifi.sta.config(ssid, password)

	ip = wifi.sta.getip()
	if ip ~= nil then
		print(ip)
	else
		print("failed to connect to WIFI")
	end
end

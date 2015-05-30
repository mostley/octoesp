local moduleName = "AccessPoint"
local M = {}
_G[moduleName] = M

local unescape = function (s)
	s = string.gsub(s, "+", " ")
	s = string.gsub(s, "%%(%x%x)", function(h)return string.char(tonumber(h, 16))end)
	return s
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function get_aps(callback)
	wifi.setmode(wifi.STATION) 

	wifi.sta.getap(function(t)
		available_aps = "" 
		if t then 
			local count = 0
			for k,v in pairs(t) do 
				ap = string.format("%-10s",k) 
				ap = trim(ap)
				available_aps = available_aps .. "<option value='".. ap .."'>".. ap .."</option>"
				count = count+1
				if (count>=10) then
					break
				end
			end 
			
			available_aps = available_aps .. "<option value='-1'>---hidden SSID---</option>"
		
		else
			print("no Access Points found")
		end
		
		callback()
	end)
end

local function set_ap(callback)
	
	print("Preparing HTML Form")
	if (file.open('configform.html','r')) then
		html = file.read()
		file.close()
	else
		html = "This Unit has been misconfigured, please reapply firmware"
	end

	html = html:gsub('($%b{})', function(w) 
		return _G[w:sub(3, -2)] or "" 
	end)

	print("Setting up Access Point")
	wifi.setmode(wifi.SOFTAP);
	wifi.ap.config({ ["ssid"] = "ESP UDP Server" })

	print("Setting up webserver")
	web_server = net.createServer(net.TCP)
    web_server:listen(80, function(conn)
      conn:on("receive", function(conn, payload)
		local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
		
		if method == nil then
			_, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
		end

		local _GET = {}
		if vars ~= nil then
			for k, v in string.gmatch(vars, "([_%w]+)=([^%&]+)&*") do
				_GET[k] = unescape(v)
			end
		end

		if _GET.password ~= nil and _GET.ssid ~= nil then
			if _GET.ssid == "-1" then
				_GET.ssid = _GET.hiddenssid
			end

			client:send("connecting...", function(c)c:close()end);

			callback(_GET.ssid, _GET.password)
		end

		payloadLen = string.len(html)
		client:send("HTTP/1.1 200 OK\r\n")
		client:send("Content-Type    text/html; charset=UTF-8\r\n")

		client:send("Content-Length:" .. tostring(payloadLen) .. "\r\n")
		client:send("Connection:close\r\n\r\n")               
		client:send(html, function(client) client:close() end);
      end)
    end)

    print("AP running Webserver started, please connect to " .. wifi.ap.getip())
end

function M.startAP(callback)
	get_aps(function()
		set_ap(callback)
	end)
end
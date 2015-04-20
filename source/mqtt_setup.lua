uuid = '67056e90-a865-11e4-b9f7-e950a788c341'
token = 'aad1725898ba71522383fe418cee9fdde1a79784'
qos = 0
--host = "meshblu.octoblu.com"
host = "54.201.232.61"
port = 1883
clientid = "ESP8266-" ..  node.chipid()

m = nil

function handle_ack_request( topic, data )
	if data then
		if data.ack and data.fromUuid and topic ~= 'messageAck' then

			if data == nil or table.getn(data) < 3 then
				data = { 0, 0, 0 }
				print("no payload, disabling LED")
			end
			
			set_color(data)

			responseData = cjson.encode( { devices = data.fromUuid, ack = data.ack, payload = data } )
			m:publish("messageAck", responseData, qos, 0, function(conn) print("sent") end)
		end
	end
end

function init_mqtt()
	print("init mqtt")

	m = mqtt.Client(clientid, 120, uuid, token)

	m:lwt("/lwt", clientid, 0, 0)

	m:on("connect", function(con) print ("connected") end)
	m:on("offline", function(con, topic, message) 
	    print ("offline, waiting 10 seconds")
		blink(boot_light_tmr_id, {0, 0, 0}, {0, 0, 255}, 500)

	     tmr.alarm(2, 10000, 0, function()
			tmr.stop(boot_light_tmr_id)
			set_color({ 0, 0, 0 })
			
	     	print ("reconnecting...") 
	        m:connect(host, port, qos, function()
	        	print ("reconnect succeeded")
	        end)
	     end)
	end)

	m:on("message", function(conn, topic, data) 
	  print(topic .. ":" ) 
	  if data ~= nil then
	    print("data: " .. data)
		
		obj = cjson.decode(data)

		if obj.topic then
			if obj.topic == 'messageAck' then
			else
				handle_ack_request(obj.topic, obj.payload)
			end
		else
			handle_ack_request('tb', obj.payload)
		end
	  end
	end)

	print("waiting for wifi")
	tmr.alarm(0, 1000, 1, function()
		if wifi.sta.status() == 5 then
			tmr.stop(0)

			tmr.stop(boot_light_tmr_id)
			blink(boot_light_tmr_id, {0, 0, 0}, {0, 0, 255}, 500)
			
			m:connect(host, port, qos, function(conn)
				
				tmr.stop(boot_light_tmr_id)
				set_color({ 0, 0, 0 })

     			print("Connected to MQTT:" .. host .. ":" .. port .." as " .. clientid )
				m:subscribe("data", qos, function(conn) 
					m:publish("data", cjson.encode({0,0,0}), qos, 0, function(conn) print("sent") end)
				end)
			end)
		end
	end)
end

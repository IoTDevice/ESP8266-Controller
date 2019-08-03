wifi.sta.disconnect()
tmr.delay(100)
wifi.setmode(wifi.STATION) 
wifi.sta.config("Your ssid","password") --modify for yor wifi info
wifi.sta.connect() 
i=0
tmr.alarm(0,2000, 1, function() 
	if wifi.sta.getip()== nil then 
		print("IP unavaiable, Waiting...")
		i=i+1
		if(i>10) then
			print("restart nodeMCU")
			node.restart()
		end
		wifi.sta.disconnect()
		wifi.sta.connect()
	else 
		tmr.stop(0)
		print("Config done, IP is "..wifi.sta.getip())
	end 
end)

led1 = 3 --GPIO0
led2 = 4 --GPIO2
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        buf = buf.."HTTP/1.1 200 OK\n\n"
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        
        if(_GET.pin == "ON1")then
              gpio.write(led1, gpio.HIGH);
			  print("led1 on")
        elseif(_GET.pin == "OFF1")then
              gpio.write(led1, gpio.LOW);
			print("led1 off")
        elseif(_GET.pin == "ON2")then
              gpio.write(led2, gpio.HIGH);
			print("led2 on")
        elseif(_GET.pin == "OFF2")then
              gpio.write(led2, gpio.LOW);
			print("led2 off")
        end
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
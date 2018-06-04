if fver then local fn,fp = "mqtt_init", {"0.6","6/3/18","RLH"} ;fver[fn] = fp ; p_local_fver(fn,fp) end
--local fn,fp = "mqtt_init", {"0.1","1/1/18","RLH"} if type(fver) == 'table' then fver[fn] = fp end 
--if p_local_fver ~= nil then p_local_fver(fn,fp) end

-- init mqtt client without logins, keepalive timer 120s
mq = mqtt.Client(D.id, 120)

-- init mqtt client with logins, keepalive timer 120sec
--m = mqtt.Client("clientid", 120, "user", "password")

-- setup Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline" 
-- to topic "/lwt" if client don't send keepalive packet
mq:lwt("/lwt", "offline", 0, 0)

mq:on("connect", function(client) D.mqtt = true ;print ("MQTT: connected") end)
mq:on("offline", function(client) D.mqtt = false;print ("MQTT: offline") end)

-- on publish message receive event
mq:on("message", function(client, topic, data) 
  p_line(_,_,"MQTT Recvd:"..topic) ; print( node.heap(), data ) 
  if data ~= nil and node.heap() >  D.heap_min
  then   
    local X = sjson.decode(data) 
    if D.dbg then p_line(60,_,"TOPIC:"..topic); print("Payload:",data) end
    if topic ~= S_TOP.cmd then 
      print("Subscribe Only: no action")       
    else -- this is a command, process comands
      --ok, pl = pcall(sjson.decode(data))
      local ok, pl = true, X
      if ok then
        --print(dump(pl,""))
        cmd_process(pl)
      else 
        print("JSON  :",pl)
      end
    end
  end
end)

-- initialize Topic to Receive Topics
S_TOP.cmd = S_TOP.cmd..D.ID.."/cmd" ; print("> MQTT command Topic:",S_TOP.cmd, "\tInitialized")
P_TOP.data = P_TOP.data..D.ID.."/" ; print("> MQTT data Topic:",P_TOP.data, "\tInitialized")
--P_TOP.config = P_TOP.data..'/config' ; print("> MQTT data Topic:",P_TOP.config, "\tInitialized")
-- for TLS: mq:connect("192.168.11.118", secure-port, 1)
--mq:connect(MQTT_SERVER.LAN_IP, MQTT_SERVER.LAN_PORT, 0, function(client)
mq:connect(MQTT.IP, MQTT.PORT, 0, function(client) 
  print(string.format("MQTT Server: %s:%d connected",MQTT.IP,MQTT.PORT))
    --[[
    Calling subscribe/publish only makes sense once the connection
    was successfully established. You can do that either here in the
    'connect' callback or you need to otherwise make sure the
    connection was established (e.g. tracking connection status or in
    mq:on("connect", function)).
    --]]
    -- subscribe topic with qos = 0
  
  for _,topic in pairs(S_TOP) do
      print("MQTT Subscription:", topic, "\tattemped")
      
      client:subscribe(topic, 0, function(client) print("MQTT Subscription:\tSUCCESSful")  end)
  end
    
 for _,topic in pairs(P_TOP) do
    print("MQTT Publish:\t\t", topic, "\t data sent")
    local msg = sjson.encode({D.ID, g_dinfo()})
    client:publish(topic, msg, 0, 0, function(client) print("MQTT Publish:","\t\tdata received"); D.mqtt = true end)   -- Turn om MQR to enable further MQTT 
 end
end,
function(client, reason)  print("failed reason: " .. reason);node.restart() end
)

mq:close();
-- you can call mq:connect again

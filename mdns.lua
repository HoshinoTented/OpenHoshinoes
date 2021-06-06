local component = require("component")
local ser = require("serialization")
local event = require("event")
local modem = component.modem

local mdns = {}
local args = table.pack(...)
local localname = args[1]

mdns.sendport = 5757
mdns.recvport = 5758

local function handle(_, localAddr, remoteAddr, localPort, distance, data)
  checkArg(2, localAddr, "string")
  checkArg(3, remoteAddr, "string")
  checkArg(4, localPort, "number")
  checkArg(5, distance, "number")

  if localPort == mdns.sendport then
      local data = ser.unserialize(data)

    if type(data) == "table" then
      if data.protocol == "mdns" then
	      local name = data.name

        if localname == name then
	        local resp = {}

          resp["protocol"] = "mdns"
	        resp["sayhello"] = "Hi! I am here!"

          modem.send(remoteAddr, mdns.recvport, ser.serialize(resp))
	      end
		  end
		end
	end
end

function mdns.request(name)
  local function recv_filter(name, _, _, localPort, _, ...)
    checkArg(1, name, "string")
    checkArg(4, localPort, "number")

    return name == "modem_message" and localPort == mdns.recvport
  end

  checkArg(1, name, "string")

  local req = {}

  req["protocol"] = "mdns"
  req["name"] = name

  modem.broadcast(mdns.sendport, ser.serialize(req))

  local _, _, remoteAddr, _, _, data = event.pullFiltered(5, recv_filter)

  if not data == nil then
    local data = ser.unserialize(data)

    if type(data) == "table" and data.protocol == "mdns" then
      return remoteAddr
	  end
	end

  return nil
end

checkArg(1, localname, "string")

assert(modem.open(mdns.sendport))
assert(modem.open(mdns.recvport))

event.listen("modem_message", handle)

return mdns
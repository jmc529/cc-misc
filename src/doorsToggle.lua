local keyHandler = require("keyHandler")
local ecc = require("libs/ecc")
peripheral.find("modem", rednet.open)
local tArgs = {...}
local sKey, pKey = keyHandler.loadKeys()
local sskTable = {[1715] = keyHandler.loadSharedSecret(sKey, ".keys/1715.key.pub")}

local function send(message)
  for k,v in pairs(sskTable) do
    rednet.send(k, ecc.encrypt(message, v), "toggle-doors")
  end
end

if #tArgs == 0 then
  send("toggle")
elseif tostring(tArgs[1]) == "open" then
  send("open")
elseif tostring(tArgs[1]) == "close" then
  send("close")
end

rednet.close()

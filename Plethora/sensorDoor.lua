local keyHandler = require("keyHandler")
local ecc = require("libs/ecc")

if not fs.exists(".keys/215.key.pub") then
  shell.run("pastebin", "get", "GnMwATUkQY", ".keys/215.key.pub")
end

local sensor = peripheral.wrap("left")
local redstoneSide = "left"
rednet.open("right")
local playerList = {["58b4ae54-1489-47f0-a84d-79131461073e"] = true,
                    ["c524925d-1b9b-47f3-8c2c-1547a64c80ce"] = true}
local triggerRadius = 3
local sKey, pKey = keyHandler.loadKeys()
local ssk = keyHandler.loadSharedSecret(sKey, ".keys/215.key.pub")
local toggle = false

parallel.waitForAny(
  function()
    while true do
      if not toggle then
        for _, entity in pairs(sensor.sense()) do
          if playerList[entity.id] then
            if math.abs(entity.x) < triggerRadius
              and math.abs(entity.z) < triggerRadius
              and math.abs(entity.y) < triggerRadius then
                rs.setOutput(redstoneSide, true)
                break
            end
          else
            rs.setOutput(redstoneSide, false)
          end
        end
      else
        coroutine.yield()
      end
    end
  end,
  function()
    while true do
      local id, cipher = rednet.receive("toggle-doors")
      local message = tostring(ecc.decrypt(cipher, ssk))
      print(message)
      if message == "open" then
        toggle = true
      elseif message == "close" then
        toggle = false
      elseif message == "toggle" then
        toggle = not toggle
      end
      rs.setOutput(redstoneSide, toggle)
    end
  end
)

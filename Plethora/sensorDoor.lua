local sensor = peripheral.wrap("left")
local redstoneSide = "left"
local player = "58b4ae54-1489-47f0-a84d-79131461073e"
local triggerRadius = 3

while true do
  for _, entity in pairs(sensor.sense()) do
    if player == entity.id then
      if math.abs(entity.x) < triggerRadius
        and math.abs(entity.z) < triggerRadius
        and math.abs(entity.y) < triggerRadius then
          rs.setOutput(redstoneSide, true)
      end
      break
    else
      rs.setOutput(redstoneSide, false)
    end
  end
end

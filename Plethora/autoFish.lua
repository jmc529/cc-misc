local ni = peripheral.find("neuralInterface")
local mcID = "minecraft:fishing_rod"
local reeled = 0
local bobberLevel = nil
local oldLevel = 0

while true do
    local sensed = ni.sense()
    for _, entity in pairs(sensed) do
        if entity.key ==  "minecraft:fishing_bobber" then
            bobberLevel = entity.y
            local diff = math.abs(bobberLevel - oldLevel)
            if 4 > diff and diff > 1 then
                local eq = ni.getEquipment()
                if eq.list()[1].name == mcID then
                    ni.use()
                    ni.use()
                    reeled = reeled + 1
                    term.clear()
                    term.setCursorPos(1,1)
                    print("Reeled in: "..reeled)
                end
            else
                oldLevel = bobberLevel
            end
        end
    end
end

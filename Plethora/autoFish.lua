local ni = peripheral.find("neuralInterface")
local mcRN = "item.minecraft.fishing_rod"
local meta = ni.getMetaOwner()
local heldItem = nil
local seaLevel = nil
local reeled = 0
local swap = -1

-- Hard coded thresholds that effect catch likelihood
local dataCount = 3 -- how many time sea level is checked, 3 to 5 seems good
local dipThreshhold = 0.08 -- how low bobber has to get before reeling in, varies greatly
local castTime = 2 -- how long to wait after casting to begin the while loop, increase if you have a large cast time
local turnRadius = 10 -- turn to avoid getting bobber caught on fish entity on the way out

-- Data logging, for debugging
local c = ni.canvas()
local y = 5
local x = 25
local cWidth, cHeight = c.getSize()
local logging = false
local fontSize = 0.5
local lineHeight = 4

local function findSeaLevel()
    local seaLevels = {}
    for _, entity in pairs(ni.sense()) do
        if entity.key ==  "minecraft:fishing_bobber" then
            for i = dataCount, 1, -1 do
                for _, entity in pairs(ni.sense()) do
                    if entity.key ==  "minecraft:fishing_bobber" then
                        table.insert(seaLevels, entity.y)
                    end
                end
            end
        end
    end
    table.sort(seaLevels)
    local level = seaLevels[math.ceil(dataCount / 2)]
    if level then
        local messageL = "Sealevel:"..level
        c.clear()
        c.addText({ cWidth - string.len(messageL) - x, y }, messageL, 0xFFFFFFFF, fontSize)
    end
    return level or nil
end


while true do
    meta = ni.getMetaOwner()
    heldItem = meta.heldItem
    if heldItem and heldItem.getMetadata()[1].rawName == mcRN then
        if not seaLevel then
            seaLevel = findSeaLevel()
        else
            for _, entity in pairs(ni.sense()) do
                if entity.key ==  "minecraft:fishing_bobber" then
                    local diff = math.abs(entity.y - seaLevel)

                    if logging then
                        c.clear()
                        c.addText({ cWidth - string.len(""..diff) - x, y }, ""..diff, 0xFFFFFFFF, fontSize)
                    end

                    if diff > dipThreshhold then
                        ni.use()
                        -- prevent fish entity from knocking bobber (other option would be to wait again)
                        ni.look(meta.yaw + (swap * turnRadius), meta.pitch)
                        swap = swap * -1
                        ni.use()
                        -- prevent premature reeling in
                        os.sleep(castTime)
                        reeled = reeled + 1
                        term.clear()
                        term.setCursorPos(1,1)
                        local messageR = "Reeled in: "..reeled
                        print(messageR)
                        c.clear()
                        c.addText({ cWidth - string.len(messageR) - x, y }, messageR, 0xFFFFFFFF, fontSize)
                    end
                end
            end
        end
    else
        seaLevel = nil
        if logging then
            c.clear()
            c.addText({ cWidth - string.len("Sea level nil") - x, y }, "Sea level nil", 0xFFFFFFFF, fontSize)
        end
    end
end

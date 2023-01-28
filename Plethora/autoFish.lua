local ni = peripheral.find("neuralInterface")
local mcRN = "item.minecraft.fishing_rod"
local meta = ni.getMetaOwner()
local heldItem = nil
local seaLevel = nil
local reeled = 0
local swap = -1

-- Hard coded thresholds that effect catch likelihood
local dataCount = 3 -- how many time sea level is checked, 3 to 5 seems good
local dipThreshold = 0.08 -- how low bobber has to get before reeling in, varies greatly
local castTime = 2 -- how long to wait after casting to begin the while loop, increase if you have a large cast time
local turnRadius = 10 -- turn to avoid getting bobber caught on fish entity on the way out

-- Data logging, for debugging
local y = 5
local x = 25
local c = ni.canvas()
local cWidth, _ = c.getSize()
local logging = false
local fontSize = 0.5

local function log(str)
    c.clear()
    c.addText({ cWidth - string.len(str) - x, y}, str, 0xFFFFFFFF, fontSize)
end

local function findSeaLevel()
    local seaLevels = {}
    for _, entity in pairs(ni.sense()) do
        if entity.key == "minecraft:fishing_bobber" then
            for i = dataCount, 1, -1 do
                for _, bobber in pairs(ni.sense()) do
                    if bobber.key ==  "minecraft:fishing_bobber" then
                        table.insert(seaLevels, bobber.y)
                    end
                end
            end
        end
    end
    table.sort(seaLevels)
    local average = math.ceil(dataCount / 2)
    local level = seaLevels[average]
    if math.abs(level - seaLevels[average + 1]) < 1 and
    math.abs(level - seaLevels[average - 1]) < 1 then
        log("Sealevel:"..level)
        return level
    end
    return nil
end

while true do
    meta = ni.getMetaOwner()
    heldItem = meta.heldItem
    if heldItem and heldItem.getMetadata()[1].rawName == mcRN then
        if not seaLevel then
            seaLevel = findSeaLevel()
        else
            local bobberFound = false
            for _, entity in pairs(ni.sense()) do
                if entity.key ==  "minecraft:fishing_bobber" then
                    local diff = math.abs(entity.y - seaLevel)

                    if logging then log(tostring(diff)) end

                    if diff > dipThreshold then
                        ni.use()
                        -- prevent fish entity from knocking bobber (other option would be to wait again)
                        ni.look(meta.yaw + (swap * turnRadius), meta.pitch)
                        swap = swap * -1
                        ni.use()
                        -- prevent premature reeling in
                        os.sleep(castTime)
                        reeled = reeled + 1
                        log("Reeled in: "..reeled)
                    end
                    bobberFound = true
                end
            end

            -- cast if server resets
            if not bobberFound then
                ni.use()
            end
        end
    else
        seaLevel = nil
        if logging then log("Sea level reset") end
    end
end

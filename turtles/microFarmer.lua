
local seeds = { ["minecraft:wheat_seeds"] = true, ["minecraft:carrot"] = true, ["minecraft:potato"] = true, ["minecraft:beetroot_seeds"] = true }
local currentSeed = 1

local function plantSeeds()
    turtle.dig()
    for i=1, 16 do
        local item = turtle.getItemDetail(i)
        if item and seeds[item.name] then
            turtle.select(i)
            turtle.place()
            break
        end
    end
end

local function harvest(block)
    if block.name == "minecraft:beetroots" then
        if block.state.age == 3 then
            turtle.dig()
            plantSeeds()
            return true, block.name
        end
    elseif block.tags["computercraft:turtle_hoe_harvestable"]
        and block.state.age == 7 then
            turtle.dig()
            plantSeeds()
            return true, block.name
    end
    return false
end

local function buildFarm()
    local ok, block = turtle.inspect()
    if not ok then
        plantSeeds()
    end
    if block ~= "No block to inspect" then
        local ok, block = harvest(block)
    end
end

local function boneMeal()
    for slot=1, 16 do
        local item = turtle.getItemDetail(slot)
        if item and item.name == "minecraft:bonemeal" then
            for count=1, item.count do
                buildFarm()
                turtle.select(slot)
                turtle.place()
            end
        end
    end
end

while true do
    for i=1,4 do
        buildFarm()
        turtle.turnRight()
    end
    os.sleep(300)
end
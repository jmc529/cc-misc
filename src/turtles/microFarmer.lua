local chestName = "sc-goodies:diamond_chest_1742"
local chest = peripheral.wrap(chestName)
local seeds = { ["minecraft:wheat_seeds"] = true, ["minecraft:carrot"] = true, ["minecraft:potato"] = true, ["minecraft:beetroot_seeds"] = true }
local currentSeed = 1

local function splitString(s, sep)
    local t = {}
    for slice in string.gmatch(s, "([^" .. sep .. "]+)") do
        table.insert(t, slice)
    end
    return unpack(t)
end

local function getItemCount(items)
    local t = {}
    for _,v in pairs(items) do
        if not t[v.name] then
            t[v.name] = v.count
        else
            t[v.name] = t[v.name] + v.count
        end
    end
    return t
end

local function compare(old, new)
    local oCount = getItemCount(old)
    local nCount = getItemCount(new)
    local diffTable = {}
    for k,v in pairs(nCount) do
        if oCount[k] then
            local diff = v - oCount[k]
            if diff ~= 0 then
                diffTable[v] = diff
            end
        else print(k,v) end
    end
    return diffTable
end

local function clearInventory()
    local turtles = peripheral.getNames()
    for k, v in pairs(turtles) do
        if v:find("turtle") then
            local old = chest.list()
            for i=1, 16 do
                chest.pullItems(v, i)
            end
            local new = chest.list()
            local diff = compare(old, new)
            for i=1, 108 do
                local i = chest.getItemDetail(i)
                for k, v in pairs(diff) do
                    if seeds[k] and i.name == k then
                        chest.pushItems(v, i, 4)
                        break
                    end
                end
            end
        end
    end
end

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
            return true, block
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

parallel.waitForAny(
    function ()
        while true do
            for i=1,4 do
                buildFarm()
                turtle.turnRight()
            end
            os.startTimer(600)
            os.pullEvent("timer")
        end
    end,
    function ()
        local id, message = rednet.receive()
        if message:find("bonemeal") then
            local _,item,count = message:splitString("|")
            -- local chest = peripheral.find("sc-goodies:diamond_chest")
            -- local itemList = getTotal(chest)
            clearInventory()
            -- get item from chest
            while itemList[item] < count do
                boneMeal()
                -- itemList = getTotal(chest)
            end
            clearInventory()
        elseif  message == "clear" then
            clearInventory()
        end
    end
)

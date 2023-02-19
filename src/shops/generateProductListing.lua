-- For MSKS, but can be modified for other formats
local DATA_PATH = "/"
local LISTING_NAME = "listing" 
local INVENTORIES = { "chest" }
local STORE = "" --change to mall/location

local function getLastString(s, sep)
    local t = {}
    for slice in string.gmatch(s, "([^" .. sep .. "]+)") do
        table.insert(t, slice)
    end
    return t[#t]
end

local function rawMeta(item)
    local meta = ""
    if item.enchantments ~= nil then
        meta = getLastString(item.enchantments[1].name, ":")
        meta = meta.."_"..item.enchantments[1].level
    else
        meta = getLastString(item.rawName, ".")
    end
    return meta
end

local function genericItem(item)
    local displayName = item.enchantments and item.enchantments[1].displayName or item.displayName
    local meta = rawMeta(item)
    print("How much should we charge for: " .. meta)
    local price = tonumber(read())

    return {
        ["label"] = displayName,
        ["price"] = price,
        ["id"] = item.name,
        ["metaname"] = STORE..meta,
        ["nbt"] = nil or item.nbt
    }
end

local function parseChests(inventories)
    local listing = {}
    for _, chest in pairs(inventories) do
        chest = peripheral.wrap(chest)
        local inventory = chest.list()
        for index, _ in pairs(inventory) do
            local item = chest.getItemDetail(index)
            local meta = rawMeta(item)
            if listing[meta] == nil then
                listing[meta] = genericItem(item)
            end
        end
    end
    return listing
end

local function writeListing()
    local listing = parseChests(INVENTORIES)
    local products = fs.open(fs.combine(DATA_PATH, LISTING_NAME), "w")
    products.write("{")
    for _, v in pairs(listing) do
        products.write("{")
        for k, v in pairs(v) do
            products.write(k)
            products.write("=")
            if k == "price" then
                products.write(""..v..",")
            else
                products.write("\""..v.."\",")
            end
        end
        products.write("},")
    end
    products.write("}")
    products.close()
end

writeListing()
local INVENTORIES = { "chest" }
local SELF = { "turtle" }

local function getLastString(s, sep)
    local t = {}
    for slice in string.gmatch(s, "([^" .. sep .. "]+)") do
        table.insert(t, slice)
    end
    return t[#t]
end

local function rawMeta(item)
    local meta = ""
    meta = getLastString(item.enchantments[1].name, ":")
    meta = meta.."_"..item.enchantments[1].level
    return meta
end

local function parseChests()
    local listing = {}
    for _, v in pairs(INVENTORIES) do
        local chest = peripheral.wrap(v)
        local inventory = chest.list()
        for index, _ in pairs(inventory) do
            local item = chest.getItemDetail(index)
            local meta = rawMeta(item)
            table.insert(listing, {index = index, meta = meta})
        end
    end
    return listing
end

local function sortOrder(listing)
    table.sort(listing, function (k1, k2) return k1.meta < k2.meta end)
    for _, v in pairs(INVENTORIES) do
        local chest = peripheral.wrap(v)
        for index, item in ipairs(listing) do
            if item.index ~= index then
                chest.pushItems(SELF, item.index)
                chest.pushItems(SELF, index)
            end
        end
    end
end

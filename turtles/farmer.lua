local bta = require("bta")

if (bta == nil) then
	shell.run("pastebin get MdD051uF bta")
	bta = require("bta")
end

local seeds = { "minecraft:seeds", "minecraft:carrots", "minecraft:potato", "minecraft:beetroot_seed"}
local currentSeed = 1

local function buildFarm()
end

local function plantSeeds()
end

local function harvest()
end
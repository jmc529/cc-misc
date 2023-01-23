local bta = require("bta")

if (bta == nil) then
	shell.run("pastebin get MdD051uF bta")
	bta = require("bta")
end

local treeMaxHeight = {['oak'] = 11, ['spruce'] = 12}
local treeLocations = {{vectorBottom, vectorTop}}

--[[
Builds a farm of the tree type.
@param type, should be a string of supported types check treeMaxHeight 
	or nil, if nil the height will be placed at 8
@count the total number of trees to plant
]]--
local function buildForest(type, count)
	--flatten and excavate 5x5 up to height around tree location,
	--place torches on outside corners if not already occupied by torches
	--place down dirt block below tree location, place down tree, save top and bottom location as vectors
end

local function harvestTrees()
	for i=1,#treeLocations do
		location = treeLocations[i][0]
		location = vector.new(treeLocations[i].x-1, treeLocations[i].y, treeLocations[i].z)
		bta.goTo(location)
		--turn towards tree, mine foward once
		bta.goTo(treeLocations[i][1], turtle.digUp())
		bta.goTo(location)
		--turn towards tree, plant sapling
	end
end

local function sweepSaplings()
	--look for saplings in our space
end

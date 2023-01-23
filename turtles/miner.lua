--Usage:
--filename <width> <length> <hole(0) or mine(1)> [<depth>] [<height>]
--This program needs access to a gps system and a chest to the left of it to work.
local args = {...}
local bta = require("bta")

if (bta == nil) then
	shell.run("pastebin get MdD051uF bta")
	bta = require("bta")
end

if #args < 3 then
	print("Usage:\nfilename <width> <length> <hole(0) or mine(1)> [<depth>]")
	return
end

local gpsMode = true
if gps.locate(5) == nil then 
	gpsMode = false
end

--Variables--
--args--
local width = tonumber(args[1])
local length = tonumber(args[2])
local mineType = tonumber(args[3])
local depth = #args > 3 and tonumber(args[4]) or 0
local checkInventoryCounter = 0
--vectors--
local locationVector = gpsMode and vector.new(gps.locate(5)) or bta.getPosition()
local returnVector = locationVector
local locationDirection = bta.turn.getDirection()
local destinationVector = locationVector + vector.new(width, depth, length)
--others--
local trashMined = 0
local itemsMined = 0


--Calculating fuel
local fuelTotal = width*length
fuelTotal = depth > 0 and fuelTotal*depth or fuelTotal
--Fuel buffer 
fuelTotal = fuelTotal+(locationVector.y*3)
local currentFuel = turtle.getFuelLevel()

repeat
	if mineType == 0 then
		if currentFuel <= fuelTotal then 
			print("I need: "..fuelTotal-currentFuel.." to complete this trip.")
		end
	elseif mineType == 1 then
		fuelTotal = math.ceil(fuelTotal/3)
		if currentFuel <= fuelTotal then 
			print("I need: "..fuelTotal-currentFuel.." to complete this trip.")
		end
	else
		print("Your third variable must be either 0 for a hole or 1 for an efficent mine.")
	end
	if turtle.getFuelLevel() < fuelTotal then
		print("Give me some fuel and hit enter!")
		io.read()
		bta.refuel(data.count)
	end
until turtle.getFuelLevel() >= fuelTotal


--Functions--
local function testSlots(backToMine)
	spots = 16
	for i = 1, spots do
		if turtle.getItemSpace(i) > 20 then
			spots = spots - 1
		end
	end
	if spots < 8 or (backToMine ~= nil and backToMine) then
		--Stores loc--
		local loc = gpsMode and vector.new(gps.locate(5)) or bta.getPosition()
		--Go to chest by first going horizontally incase we are using "minetype1"--
		local returnHole = returnVector
		returnHole.y = loc.y
		bta.goTo(returnHole)
		bta.goTo(returnVector)
		--turn towards chest--
		bta.turn.toCardinal(locationDirection)
		bta.turn.spin(1, 2)
		--Dump inventory--
		for i = 1, 16 do
			local item = turtle.getItemDetail(i)
			if item ~= nil and item.count > 0 then
				if string.match(item.name, "ore") then
					itemsMined = itemsMined + item.count
				else
					trashMined = trashMined + item.count
				end
				turtle.select(i)
				turtle.drop()
			end
		end
		--returns to location--
		if backToMine == nil or not backToMine then 
			bta.goTo(loc)
		end
  	end
end

local function mineAll()
	turtle.digDown()
	checkInventoryCounter = checkInventoryCounter + 1
	if checkInventoryCounter >= 500 then
		testSlots()
		checkInventoryCounter = 0
	end
end

local function mineOre()
	turtle.dig()
	local downSucc, down = turtle.inspectDown()
	local upSucc, up = turtle.inspectUp()
	if downSucc and string.match(down.name, "ore") then
		turtle.digDown()
	end
	if upSucc and string.match(up.name, "ore") then
		turtle.digUp()
	end
	checkInventoryCounter = checkInventoryCounter + 1
	if checkInventoryCounter >= 500 then
		testSlots()
		checkInventoryCounter = 0
	end
end

local function main()
	--since there is no check for bedrock you should be carfeul and only push your turtle to y >= 10--
	if mineType == 0 then
		bta.boxTo(destinationVector, mineAll)
	elseif mineType == 1 then
		--create hole for turtle to use to return to surface--
		local distance = destinationVector - locationVector
		local function whichWay() 
			if distance.y > 0 then 
				return turtle.digUp
			elseif distance.y < 0 then
				return turtle.digDown
			end
		end
		local holeVector = locationVector
		holeVector.y = destinationVector.y
		local dig = whichWay()
		bta.goTo(holeVector, dig)
		--mine layers
		local layerVector, y = destinationVector
		for i=0, math.abs(distance.y), 3 do
			y = (distance.y < 0) and (destinationVector.y + i) or (destinationVector.y - i)
			layerVector.y = y
			locationVector.y = y
			bta.goTo(locationVector)
			bta.boxTo(layerVector, mineOre)
		end
	end
	testSlots(true)
	print(channel,channel,"Trash mined: "..tostring(trashMined))
	print(channel,channel,"Items mined: "..tostring(itemsMined))
end

main()
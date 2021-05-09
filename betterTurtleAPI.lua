--[[
A robust turtle API for computercraft that improves upon functions and adds new ones.
Pastebin: MdD051uF
    Functions:
        calibrate() to the cardinal directions
        boxTo(destinationVector[, fn]) moves to every location between two coordinates
        getPostion() returns the turtle's position as a vector
        goTo(vector[, fn]) moves the turtle to a specific vector
        move(direction[, fn][, count]) multiple times, foward-back-up-down
        refuel() checks inventory for fuel
        xMovement(distance[, fn]) moves the turtle along the x-axis
        yMovement(distance[, fn]) moves the turtle along the y-axis
        zMovement(distance[, fn]) moves the turtle along the z-axis
    Packages:
        turn.
            north() (etc..) face the four cardinal directions
            spin(direction[, count]) multiple times
            toCardinal(str) face cardinal direction by user input
            getDirection() get current direction as a string value
*It is assumed you calibrate() or face the turtle north, or the program won't function as expected. This is currently 
done when the API is loaded and shouldn't be edited out.

This API should be used with lua's require method

@author informer
@date February 14th 2019
@version 0.1.2
]]--
local BTA = {}
---Local Variables---
local currentDirection = 0
local gpsMode = true
local position

---Functions--
--[[
Attempts to calibrate the the turtle using the gps.
]]--
function BTA.calibrate()
    if gps.locate(5) == nil then
        gpsMode = false
        print("Please enter in the exact coordinates of the turtle\nX:")
        x = tonumber(read())
        print("\nY:")
        y = tonumber(read())
        print("\nZ:")
        z = tonumber(read())
        position = vector.new(x, y, z)
        print("Please enter the direction the turtle is facing <N,E,W,S>:")
        direction = read()
        if not direction:find("N") and not direction:find("E") and not direction:find("W") and not direction:find("S") then
            BTA.calibrate()
        end
        dirDic = {["N"] = 0, ["E"] = 1, ["S"] = 2, ["W"] = 3}
        currentDirection = dirDic[direction]

    else
        if turtle.getFuelLevel() < 1 then
            error("Please supply your turtle with fuel for gps calibration.")
        end

        local location1 = vector.new(gps.locate(5))
        position = location1
        turtle.forward()
        local location2 = vector.new(gps.locate(5))
        turtle.back()
        local location3 = location2 - location1
        if location3.z == -1 then
            currentDirection = 0
        elseif location3.x == 1 then
            currentDirection = 1
        elseif location3.z == 1 then
            currentDirection = 2
        elseif location3.x == -1 then
            currentDirection = 3
        end
    end
end

--[[
Will move the turtle to the specifed vector, hitting every cooridnate in between the two points.
@parameter destinationVector the coordinates to travel to
@optionalParameter fn a function to apply at each step
@return true if the turtle is able to travel to the vector
]]--
function BTA.boxTo(destinationVector, fn)
    local location
    if gpsMode then
        location = vector.new(gps.locate(5))
    else
        location = position
    end
    local distance = destinationVector - location
    local coordinates = {}

    --[[
    Helper function to move along a layer. Width and length should be found by subtracting the turtle's
    current location from it's next destination location.
    @oarameter y the y value to add
    @parameter to the vector we are heading to
    @parameter from the vector we are coming from
    ]]--
    local function addLayer(y, to, from)
        local length = to - from
        local switch, x, z = 0
        for i=0, math.abs(length.x) do
            x = (length.x > 0) and (from.x + i) or (from.x - i)
            z = (switch > 1) and from.z or to.z
            switch = (switch > 1) and 0 or 2
            coordinates[#coordinates+1] = vector.new(x, y, z)
        end
    end

    --Find coordinates to traverse
    if distance.y == 0 then
        addLayer(location.y, destinationVector, location)
    else
        local ySpaces = (distance.y > 0) and 1 or -1
        local locY, to, from, y, temp = location.y, destinationVector, location
        for i=0, math.abs(distance.y) do
            y = (distance.y > 0) and (locY + i) or (locY - i)
            addLayer(y, to, from)
            temp = from
            from = to
            to = temp
        end
    end

    --go to said coordinates
    for i=1, #coordinates do
        BTA.goTo(coordinates[i], fn)
    end

    --odd fix (ends up on oppisite side)
    if location:dot(destinationVector)%2 == 1 then
        return BTA.goTo(destinationVector)
    end

    --check for truth
    local location
    if gpsMode then 
        location = vector.new(gps.locate(5))
    else 
        location = position
    end

    --cross product of same vector is 0 vector, dot product of anything else will result in 0
    if location:cross(destinationVector):dot(vector.new(1,1,1)) == 0 then
        return true
    else
        return false, destinationVector
    end
end

--[[
Returns the turtles postion, the relevance of this is mainly for when you 
are working in a nonegps enviorment.
@return postion of the turtle as a vector
]]--
function BTA.getPostion()
    return gpsMode and vector.new(gps.locate(5)) or postion
end

--[[
Will move the turtle to the specifed vector.
@parameter destinationVector the coordinates to travel to
@optionalParameter fn a function to apply at each step
@return true if the turtle is able to travel to the vector
]]--
function BTA.goTo(destinationVector, fn)
    local location
    if gpsMode then
        location = vector.new(gps.locate(5))
    else
        location = position
    end
    local distance = destinationVector - location
       
    BTA.yMovement(distance.y, fn)
    BTA.xMovement(distance.x, fn)
    BTA.zMovement(distance.z, fn)

    local location
    if gpsMode then
        location = vector.new(gps.locate(5))
    else
        location = position
    end
    --see boxTo for explanation
    if location:cross(destinationVector):dot(vector.new(1,1,1)) == 0 then
        return true
    else
        return false, destinationVector
    end
end

--[[
Moves the turtle in n number of blocks in one direction. Optionally applying a function
during each movement.

@parameter direction the direction to move, 1:forward, 2:back, 3:up, 4:down
@optionalParameter fn a function to apply at each step
@optionalParameter count the amount of blocks to traverse
@return true if unimpeded; if false returns the remaining count
]]--
function BTA.move(direction, fn, count)
    local count = (count ~= nil) and count or 1
    if fn ~= nil then
        fn()
    end

    --help function
    local function counter()
        count = count - 1
        if fn ~= nil then
            fn()
        end
    end

    while count > 0 do
        if direction == 1 or string.lower(direction) == "forward" then
            if turtle.forward() then
                counter()
            else
                return false, count
            end
        elseif direction == 2 or string.lower(direction) == "back" then
            if turtle.back() then
                counter()
            else
                return false, count
            end
        elseif direction == 3 or string.lower(direction) == "up" then
            if turtle.up() then
                counter()
            else
                return false, count
            end
        elseif direction == 4 or string.lower(direction) == "down" then
            if turtle.down() then
                counter()
            else
                return false, count
            end
        end
    end
    return true
end

---Turn package---
turn = {}

--[[
Gets the direction the turtle is currently facing.
@return number representing the direction the turtle is facing
]]--
function turn.getDirection()
    local direction = nil
    local currDir = currentDirection % 4
    if currDir == 0 then
        return "north"
    elseif currDir == 1 then
        return "east"
    elseif currDir == 2 then
        return "south"
    elseif currDir == 3 then
        return "west"
    end
end

--[[
Turns the turtle to face a cardinal direction. 
@parameter str a string representing the cardinal direciton to turn the turtle towards
]]--
function turn.toCardinal(str)
    if string.lower(str) == "north" then
        turn.north()
    elseif string.lower(str) == "south" then
        turn.south()
    elseif string.lower(str) == "east" then
        turn.east()
    elseif string.lower(str) == "west" then
        turn.west()
    end
end

--[[
Turns the turtle in a set direction n times
@parameter direction the direction to turn the turtle in, -1:left, 1:right
@optionalParameter count the amount of times to turn the turtle
]]--
function turn.spin(direction, count)
    local count = (count ~= nil) and count or 1
    
    if direction == -1 or string.lower(direction) == "left" then
        while (count > 0) do
            turtle.turnLeft()
            currentDirection = currentDirection - 1
            count = count - 1
        end
    elseif direction == 1 or string.lower(direction) == "right" then
        while (count > 0) do
            turtle.turnRight()
            currentDirection = currentDirection + 1
            count = count - 1
        end
    end
end

function turn.north()
    local n = currentDirection % 4
    if n ~= 3 then
        turn.spin(-1, n)
    else
        turn.spin(1)
    end
end

function turn.east()
    local n = (currentDirection % 4) - 1
    if n ~= -1 then
        turn.spin(-1, n)
    else
        turn.spin(1)
    end
end

function turn.west()
    local n = currentDirection % 4
    if (n-1) ~= -1 then 
        turn.spin(1, math.abs(n-3))
    else
        turn.spin(-1)
    end
end

function turn.south()
    local n = currentDirection % 4
    if n ~= 3 then
        turn.spin(1, math.abs(n-2))
    else
        turn.spin(-1)
    end
end

BTA.turn = turn
--Turn package end---

--[[
Steps through each slot in your turtle's inventory looking for fuel. If fuel is found, the turtle 
will fuel up to the limit of fuel available or the configured cap set on it. If no fuel is found
the turtle attempts to go back to the vector, refueling station, given to it as a parameter.
@return true if the turtle is able to refuel and the current fuel level
]]--
function BTA.refuel()
    local fuel = turtle.getFuelLevel()
    local limit = turtle.getFuelLimit()
    if fuel == "unlimited" then
        return true, turtle.getFuelLevel()
    end

    for i=1,16 do
        turtle.select(i)
        if turtle.refuel(0) then
            while turtle.getFuelLevel() < turtle.getFuelLimit() and turtle.getItemCount(i) > 0 do
                turtle.refuel(1)
            end
            return true, turtle.getFuelLevel()            
        end
    end

    return false, turtle.getFuelLevel()
end

--[[
oves the turtle along the X axis.
    *distance can be found by subtracting your destiation vector from your
    location vector
@parameter distance the amount of blocks to move the turtle
@optionalParameter fn a function to apply at each step
@return true if the turtle is unimpeded
]]--
function BTA.xMovement(distance, fn)
    if distance < 0 then
        BTA.turn.west()
        local truth, count = BTA.move("forward", fn,  math.abs(distance))
        position.x = position.x - math.abs(distance)
        if not truth then 
            return false
        end
    elseif distance > 0 then
        BTA.turn.east()
        local truth, count = BTA.move("forward", fn,  math.abs(distance))
        position.x = position.x + math.abs(distance)
        if not truth then 
            return false
        end
    end
    return true
end

--[[
Moves the turtle along the Y axis.
    *distance can be found by subtracting your destiation vector from your
    location vector
@parameter distance the amount of blocks to move the turtle
@optionalParameter fn a function to apply at each step
@return true if the turtle is unimpeded
]]--
function BTA.yMovement(distance, fn)
    if distance < 0 then
        local truth, count = BTA.move("down", fn,  math.abs(distance))
        position.y = position.y - math.abs(distance)
        if not truth then 
            return false
        end
    elseif distance > 0 then
        local truth, count = BTA.move("up", fn,  math.abs(distance))
        position.y = position.y + math.abs(distance)
        if not truth then
            return false
        end
    end
    return true
end

--[[
Moves the turtle along the Z axis.
    *distance can be found by subtracting your destiation vector from your
    location vector
@parameter distance the amount of blocks to move the turtle
@optionalParameter fn a function to apply at each step
@return true if the turtle is unimpeded
]]--
function BTA.zMovement(distance, fn)
    if distance < 0 then
        BTA.turn.north()
        local truth, count = BTA.move("forward", fn,  math.abs(distance))
        position.z = position.z - math.abs(distance)
        if not truth then
            return false
        end
    elseif distance > 0 then
        BTA.turn.south()
        local truth, count = BTA.move("forward", fn,  math.abs(distance))
        position.z = position.z + math.abs(distance)
        if not truth then
            return false
        end
    end
    return true
end

BTA.calibrate()

return BTA
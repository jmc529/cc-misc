--[[
A robust turtle API for computercraft that improves upon functions and adds new ones.
Pastebin: MdD051uF
    Functions:
        getPosition() returns the turtle's position as a vector
        boxTo(destinationVector[, fn]) moves to every location between two coordinates
        goTo(vector[, fn]) moves the turtle to a specific vector
    Packages:
        move.
            move(direction[, fn][, count]) multiple times, forward-back-up-down
            refuel() checks inventory for fuel
            xMovement(distance[, fn]) moves the turtle along the x-axis
            yMovement(distance[, fn]) moves the turtle along the y-axis
            zMovement(distance[, fn]) moves the turtle along the z-axis
        turn.
            calibrate() to the cardinal direction
            north() (etc..) face the four cardinal directions
            spin(direction[, count]) multiple times
            toCardinal(str) face cardinal direction by user input
            getDirection() get current direction as a string value
*It is assumed you calibrate() or face the turtle north, or the program won't function as expected. This is currently done when the API is loaded and shouldn't be edited out.

This API should be used with lua's require method

@author lakeontario
@date January 28th 2023
@version 0.1.3
]]--
local turn = require "./modules/turn.lua"
local move = require "./modules/move.lua"
local currentDirection = 0
local gpsMode = true
local position


--[[
Returns the turtles position, the relevance of this is mainly for when you 
are working in a non-gps environment.
@return position of the turtle as a vector
]]--
function BTA.getPosition()
    return gpsMode and vector.new(gps.locate(5)) or position
end


--[[
Will move the turtle to the specified vector, hitting every coordinate in between the two points.
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
    @parameter y the y value to add
    @parameter to the vector we are heading to
    @parameter from the vector we are coming from
    ]]--
    local function addLayer(y, to, from)
        local length = to - from
        local switch, x, z = 0, 0, 0
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
        local locY, to, from, y, temp = location.y, destinationVector, location, 0, 0
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

    --odd fix (ends up on opposite side)
    if location:dot(destinationVector) % 2 == 1 then
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
Will move the turtle to the specified vector.
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

    --validate location is correct
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
Steps through each slot in your turtle's inventory looking for fuel. If fuel is found, the turtle 
will fuel up to the limit of fuel available or the configured cap set on it. If no fuel is found
the turtle attempts to go back to the vector, refueling station, given to it as a parameter.
@return true if the turtle is able to refuel and the current fuel level
]]--
local function refuel()
    local fuel = turtle.getFuelLevel()
    local limit = turtle.getFuelLimit()
    if fuel == "unlimited" then
        return true, turtle.getFuelLevel()
    end

    for i=1,16 do
        turtle.select(i)
        if turtle.refuel(0) then
            while turtle.getFuelLevel() < limit and turtle.getItemCount(i) > 0 do
                turtle.refuel(1)
            end
            return true, turtle.getFuelLevel()
        end
    end

    return false, turtle.getFuelLevel()
end

return { refuel = refuel }
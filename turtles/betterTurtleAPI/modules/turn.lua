local turn = {}
--[[
Attempts to calibrate the the turtle using the gps.
]]--
function BTA.calibrate()
    if gps.locate(5) == nil then
        gpsMode = false
        print("Please enter in the exact coordinates of the turtle\nX:")
        local x = tonumber(read())
        print("\nY:")
        local y = tonumber(read())
        print("\nZ:")
        local z = tonumber(read())
        position = vector.new(x, y, z)
        print("Please enter the direction the turtle is facing <N,E,W,S>:")
        local direction = read()
        if not direction:find("N") and not direction:find("E") and not direction:find("W") and not direction:find("S") then
            BTA.calibrate()
        end
        local dirDic = {["N"] = 0, ["E"] = 1, ["S"] = 2, ["W"] = 3}
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
Gets the direction the turtle is currently facing.
@return number representing the direction the turtle is facing
]]--
function turn.getDirection()
    local direction = currentDirection % 4
    if direction == 0 then
        return "north"
    elseif direction == 1 then
        return "east"
    elseif direction == 2 then
        return "south"
    elseif direction == 3 then
        return "west"
    end
end

--[[
Turns the turtle to face a cardinal direction. 
@parameter str a string representing the cardinal direction to turn the turtle towards
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
    count = (count ~= nil) and count or 1

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

return turn
--[[
Moves the turtle in n number of blocks in one direction. Optionally applying a function
during each movement.

@parameter direction the direction to move, 1:forward, 2:back, 3:up, 4:down
@optionalParameter fn a function to apply at each step
@optionalParameter count the amount of blocks to traverse
@return true if unimpeded; if false returns the remaining count
]]--
local function move(direction, fn, count)
    count = (count ~= nil) and count or 1
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


--[[
Moves the turtle along the X axis.
    *distance can be found by subtracting your destination vector from your
    location vector
@parameter distance the amount of blocks to move the turtle
@optionalParameter fn a function to apply at each step
@return true if the turtle is unimpeded
]]--
local function xMovement(distance, fn)
    local completed, count
    if distance < 0 then
        BTA.turn.west()
        completed, count = BTA.move("forward", fn,  math.abs(distance))
        position.x = position.x - math.abs(distance)
    elseif distance > 0 then
        BTA.turn.east()
        completed, count = BTA.move("forward", fn,  math.abs(distance))
        position.x = position.x + math.abs(distance)
    end
    return completed, count
end

--[[
Moves the turtle along the Y axis.
    *distance can be found by subtracting your destination vector from your
    location vector
@parameter distance the amount of blocks to move the turtle
@optionalParameter fn a function to apply at each step
@return true if the turtle is unimpeded
]]--
local function yMovement(distance, fn)
    local completed, count
    if distance < 0 then
        completed, count = BTA.move("down", fn,  math.abs(distance))
        position.y = position.y - math.abs(distance)
    elseif distance > 0 then
        completed, count = BTA.move("up", fn,  math.abs(distance))
        position.y = position.y + math.abs(distance)
    end
    return completed, count
end

--[[
Moves the turtle along the Z axis.
    *distance can be found by subtracting your destination vector from your
    location vector
@parameter distance the amount of blocks to move the turtle
@optionalParameter fn a function to apply at each step
@return true if the turtle is unimpeded
]]--
local function zMovement(distance, fn)
    local completed, count
    if distance < 0 then
        BTA.turn.north()
        completed, count = BTA.move("forward", fn,  math.abs(distance))
        position.z = position.z - math.abs(distance)
    elseif distance > 0 then
        BTA.turn.south()
        completed, count = BTA.move("forward", fn,  math.abs(distance))
        position.z = position.z + math.abs(distance)
    end
    return completed, count
end

return 
local modules = peripheral.find("neuralInterface")
if not modules then
	error("Must have a neural interface", 0)
end

if not modules.hasModule("plethora:sensor") then error("Must have a sensor", 0) end
-- if not modules.hasModule("plethora:scanner") then error("Must have a scanner", 0) end
if not modules.hasModule("plethora:introspection") then error("Must have an introspection module", 0) end
if not modules.hasModule("plethora:kinetic", 0) then error("Must have a kinetic agument", 0) end
if not modules.hasModule("plethora:glasses") then error("Must have overlay glasses", 0) end

local function angle_bounds(angle)
    if angle < -179 then
        angle = angle + 360
    elseif angle > 180 then
        angle = angle - 360
    end
    return angle
end

local power = 4
local override = false

local keyHandlers = {
    [keys.w] = function (owner)
        modules.launch(owner.yaw, owner.pitch, power)
    end,
    [keys.s] = function (owner)
        modules.launch(owner.yaw, angle_bounds(owner.pitch+180), power)
    end,
    [keys.space] = function (owner)
        modules.launch(owner.yaw, -90, power)
    end,
    [keys.leftShift] = function (owner)
        modules.launch(owner.yaw, 90, power)
    end,
    [keys.a] = function (owner)
        modules.launch(angle_bounds(owner.yaw-90), owner.pitch, power)
    end,
    [keys.d] = function (owner)
        modules.launch(angle_bounds(owner.yaw+90), owner.pitch, power)
    end
}

local bar_width = 1000
local bar_thickness = 10
local yellow = 70
local red = 30

local canvas = modules.canvas()
-- canvas.clear()
local inv = modules.getEquipment()
local durabilityText, overrideText, chestpieceItem
local function draw_glasses_ui()
    local chest = inv.getItemDetail(5) or {}
    canvas.clear()
    chestpieceItem = canvas.addItem({1,1}, chest.name or "minecraft:cobblestone", 2)
    local durability = (chest.durability or 1) * 100
    durabilityText = canvas.addText({40,8},string.format("%.1f", durability))
    overrideText = canvas.addText({40,16}, tostring(override))
end

draw_glasses_ui()


local doHover = false
local function update_glasses_ui()
    local chest = inv.getItemDetail(5) or {}
    chestpieceItem.setItem(chest.name or "minecraft:cobblestone", 2)
    local durability = (chest.durability or 1) * 100
    local color = 0x00ff00
    if durability < yellow then
        durabilityText.setColor(255, 255, 0)
    elseif durability < red then
        durabilityText.setColor(255, 0, 0)
    else
        durabilityText.setColor(0, 255, 0)
    end
    durabilityText.setText(string.format("%.1f", durability, color))
    overrideText.setText(tostring(override).."/"..tostring(doHover))
end

local owner = modules.getMetaOwner()
local function flight_control()
    while true do
        local _, key = os.pullEvent("key")
        if keyHandlers[key] then
            owner = modules.getMetaOwner()
            if owner.isElytraFlying or override then
                update_glasses_ui()
                keyHandlers[key](owner)
            end
        elseif key == keys.o then
            override = not override
            update_glasses_ui()
        elseif key == keys.h then
            doHover = not doHover
            if doHover then
                os.queueEvent("hover")
            end
            update_glasses_ui()
        end
    end
end

local function draw_term_ui()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    local w,h = term.getSize()
    local s = "Click to change power"
    term.setCursorPos((w - #s) / 2, h / 2)
    term.write(s)
    local ps = string.format("Power is %s", power)
    term.setCursorPos((w - #ps) / 2, h / 2 + 1)
    term.write(ps)
end

local function ui()
    while true do
        draw_glasses_ui()
        draw_term_ui()
        os.pullEvent("mouse_click")
        term.clearLine()
        term.write("?")
        power = math.max(math.min(tonumber(read()) or power, 4), 0)
    end
end

local function tick_glasses_ui()
    while true do
        sleep(10)
        update_glasses_ui()
    end
end

---comment
-- ---@param v1 Vector
-- ---@param v2 Vector
-- ---@return number
-- local function getAngle(v1,v2)
--     local den = v1:length()*v2:length()
--     if den == 0 then
--         return 90
--     end
--     return math.acos(v1:dot(v2)/den)*180/math.pi
-- end

local function getAngle(opposite, adjacent)
    local offset = -180
    -- if adjacent < 0 then
    --     offset = 180
    -- end
    if opposite < 0 and adjacent < 0 then
        offset = offset + 180
    elseif opposite < 0 then
        offset = offset + 90
    elseif adjacent < 0 then
        offset = offset + 270
    end
    if adjacent == 0 then
        return offset
    end
    return math.atan(opposite / adjacent) * 180 / math.pi + offset
end

local function hover()
    local t0 = os.epoch("utc")
    while true do
        if doHover then
            owner = modules.getMetaOwner()
            local t1 = os.epoch("utc")
            -- if owner.motionZ == 0 then
            --     owner.motionZ = 0.00001
            -- end
            local mY = owner.motionY
            -- mY = (mY - 0.138) / 0.8
            -- print(t1-t0)
            mY = (mY - 0.295)/0.8 * ((t1 - t0) / 100)-- this is *per tick*
            t0 = t1

            -- If it is sufficiently large then we fire ourselves in that direction.
            if mY > 0.5 or mY < 0 then
                local sign = 1
                if mY < 0 then sign = -1 end
                modules.launch(0, 90 * sign, math.min(4, math.abs(mY)))
            else
                sleep(0)
            end
        else
            os.pullEvent("hover")
        end
    end
end

parallel.waitForAll(flight_control, ui, tick_glasses_ui, hover)
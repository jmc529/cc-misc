local basalt = require("basalt")
local frameId = 1
local main = basalt.createFrame():setMonitor("monitor_397")

-- helper functions
local function clamp(value, min, max)
    value = value < min and min or value
    return value > max and max or value
end

-- frames
local frames = {
    main:addFrame():setPosition(1,1):setSize("parent.w", "parent.h-1"):setBackground(colors.lightGray),
    main:addFrame():setPosition(1,1):setSize("parent.w", "parent.h-1"):setBackground(colors.lightGray):hide(),
    main:addFrame():setPosition(1,1):setSize("parent.w", "parent.h-1"):setBackground(colors.lightGray):hide()
}

-- lists
local lists = {
    frames[1]:addList():setSize("parent.w-1", "parent.h"),
    frames[2]:addList():setSize("parent.w-1", "parent.h"),
    frames[3]:addList():setSize("parent.w-1", "parent.h")
}

-- scroll bars 
local scrollBarSize = 18
frames[1]:addScrollbar():setBarType("vertical")
    :setSize(1,"parent.h")
    :setPosition("parent.w", 1)
    :setMaxValue(scrollBarSize)
    :onChange(function(self, value)
        local offset = math.floor((value / scrollBarSize) * (lists[1]:getItemCount() - scrollBarSize))
        offset = value == 1 and 0 or offset
        lists[1]:setOffset(clamp(offset, 0, lists[1]:getItemCount() - scrollBarSize))
    end)
frames[2]:addScrollbar():setBarType("vertical")
    :setSize(1,"parent.h")
    :setPosition("parent.w", 1)
    :setMaxValue(scrollBarSize)
    :onChange(function(self, value)
        local offset = math.floor((value / scrollBarSize) * (lists[2]:getItemCount() - scrollBarSize))
        offset = value == 1 and 0 or offset
        lists[2]:setOffset(clamp(offset, 0, lists[2]:getItemCount() - scrollBarSize))
    end)
frames[3]:addScrollbar():setBarType("vertical")
    :setSize(1,"parent.h")
    :setPosition("parent.w", 1)
    :setMaxValue(scrollBarSize)
    :onChange(function(self, value)
        local offset = math.floor((value / scrollBarSize) * (lists[3]:getItemCount() - scrollBarSize))
        offset = value == 1 and 0 or offset
        lists[3]:setOffset(clamp(offset, 0, lists[3]:getItemCount() - scrollBarSize))
    end)

-- menubar
main:addMenubar():ignoreOffset()
        :addItem("Seen",nil,nil,1)
        :addItem("Mentions",nil,nil,2)
        :addItem("Respect",nil,nil,3)
        :setSpace(2)
        :setSize("parent.w",1)
        :setPosition(1, "parent.h")
        :onChange(function(self, value)
            if (value.args[1] ~= frameId) then
                frames[frameId]:hide()
                frameId = value.args[1]
                frames[frameId]:show()
            end
        end)


-- lists[1]:addItem("1. Entry")
-- :addItem("2. Entry",colors.yellow)
-- :addItem("3. Entry",colors.yellow,colors.green)

basalt.autoUpdate()
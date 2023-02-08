local TS_PATH = "seen/ts"
local monitor = "monitor_430"
local lastOnID = {}
local leftTimer = nil
local websocket = http.websocket("wss://chat.sc3.io/v2/3101b983-1fb7-4a1f-9ab0-a99412a8c292")
local hello, ok = websocket.receive()


--helper functions
local function writeToFile()
    local ts = fs.open(TS_PATH, "w")
    table.sort(lastOnID, function (t1, t2) return os.time(parseDateTime(t1.time)) < os.time(parseDateTime(t2.time)) end)
    for k,v in pairs(lastOnID) do
        ts.writeLine(k.."|"..v.name.."|"..v.ts)
    end
    ts.close()
end

local function splitString(s, sep)
    local t = {}
    for slice in string.gmatch(s, "([^" .. sep .. "]+)") do
        table.insert(t, slice)
    end
    return unpack(t)
end

local function parseDateTime(str, EST)
    local Y,M,D = str:match("^(%d-)[-](%d-)[-](%d-)T")
    local h,m,s = str:match("T(%d-)[:](%d-)[:](%d-)[-+Z]")
    Y,M,D = tonumber(Y) or 1, tonumber(M) or 1, tonumber(D) or 1
    h,m,s = tonumber(h) or 1, tonumber(m) or 0, tonumber(s) or 0
    if EST then
        return {year=Y, month=M, day=D, hour=(h-5), min=(m), sec=s}
    else
        return {year=Y, month=M, day=D, hour=(h+oh), min=(m+om), sec=s}
    end
end

local function formatTime(name, t)
    local time = parseDateTime(t, true)
    local ts = time.month.."\/"..time.day.."\/"..(tonumber(time.year)%100).."|"..textutils.formatTime(time.hour + (time.min/60) + (time.sec/3600), true)
    local gap = mWidth - 1 - string.len(name..ts)
    if gap > 0 then
        local space = string.rep(" ", gap)
        return name..space..ts
    else
        name:sub(1, name:len() + gap)
        return name..ts
    end
end


--load table
if fs.exists(TS_PATH) then
    local last = fs.open(TS_PATH, "r")
    while true do
        local line = last.readLine()
        if not line then
            break
        else
            local id, user, time = splitString(line, "|")
            lastOnID[id] = {user, time}
        end
    end
    last.close()
    table.sort(lastOnID, function (t1, t2) return os.time(parseDateTime(t1.time)) < os.time(parseDateTime(t2.time)) end)
end

parallel.waitForAny(
    --wait for leave event
    function ()
        while true do
            local packet, ok = websocket.receive()
            packet = textutils.unserializeJSON(packet)
            if packet.type and packet.type == "event" then
                if packet.event == "leave" then
                    lastOnID[packet.user.uuid] = {["name"] = packet.user.name, ["ts"] = packet.time}
                    if leftTimer then
                        os.cancelTimer(leftTimer)
                    end
                    leftTimer = os.startTimer(60)
                end
            end
        end
    end,
    -- write if server shutdown imminent
    function ()
        while true do
            os.pullEvent("server_restart_scheduled")
            writeToFile()
            websocket.close()
        end
    end,
    -- write if queued
    function ()
        while true do
            local e, id = os.pullEvent("timer")
            if id == leftTimer then writeToFile() end
        end
    end
)
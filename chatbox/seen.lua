local BOT_NAME = "seen"
local OPT_OUT_PATH = "seen/opt_out"
local TS_PATH = "seen/ts"
local excluded = {}
local lastOnID = {}
local lastOnName = {}
local timer = nil
local websocket = http.websocket("wss://chat.sc3.io/v2/3101b983-1fb7-4a1f-9ab0-a99412a8c292")
local hello, ok = websocket.receive()

--helper functions
local function writeToFile()
    local ts = fs.open(TS_PATH, "w")
    for k,v in pairs(lastOnID) do
        ts.write(k.."|"..v.name.."|"..v.ts)
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


-- load files
if fs.exists(OPT_OUT_PATH) then
    local opt = fs.open(OPT_OUT_PATH, "r")
    while true do
        local line = opt.readLine()
        if not line then break end
        excluded[line] = true
    end
    opt.close()
end

if fs.exists(TS_PATH) then
    local last = fs.open(TS_PATH, "r")
    while true do
        local line = last.readLine()
        if not line then
            break
        else
            local id, user, time = splitString(line, "|")
            lastOnID[id] = {user, time}
            lastOnName[user] = time
        end
    end
    last.close()
end

local function parseDateTime(str)
    local Y,M,D = str:match("^(%d-)-?(%d-)-?(%d-)")
    local h,m,s = str:match("T(%d-):(%d-):(%d-)([-+])")
    local oh,om =   str:match("([-+])(%d%d):?(%d?%d?)$")
    print(Y, M, D, h, m, s, oh, om)
    return os.time({year=Y, month=M, day=D, hour=(h+oh), min=(m+om), sec=s})
end

parallel.waitForAny(
    --wait for leave event
    function ()
        while true do
            local packet, ok = websocket.receive()
            packet = textutils.unserializeJSON(packet)
            if packet.type and packet.type == "event" and packet.event == "leave" then
              if not excluded[packet.user.uuid] then
                  lastOnID[packet.user.uuid] = {["name"] = packet.user.name, ["ts"] = packet.time}
                  lastOnName[packet.user.name:lower()] = packet.time
                  if timer then
                      os.cancelTimer(timer)
                  end
                  timer = os.startTimer(60)
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
            os.pullEvent("timer")
            writeToFile()
        end
    end
)

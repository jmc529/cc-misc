local BOT_NAME = "seen"
local OPT_OUT_PATH = "seen/opt_out"
local TS_PATH = "seen/ts"
local excluded = {}
local lastOnID = {}
local lastOnName = {}
local timer = nil

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
    return os.time({year=Y, month=M, day=D, hour=(h+oh), min=(m+om), sec=s})
end

parallel.waitForAny(
    --wait for leave event
    function ()
        while true do
            local event, user, data = os.pullEvent("leave")
            if not excluded[user.uuid] then
                lastOnID[user.uuid] = {user, data.time}
                lastOnName[user.name:lower()] = data.time
                if timer then
                    os.cancelTimer(timer)
                end
                timer = os.startTimer(60)
            end
        end
    end,
    -- timestamp and opt out
    function ()
        while true do
            local event, user, command, args = os.pullEvent("command")
            if command == "seen" then
                if #args > 0 then
                    if args[1] == "opt-out" then
                        local opt = fs.open(OPT_OUT_PATH, "a")
                        opt.write(user.uuid)
                        opt.close()
                    else
                        local inputUser = args[1]
                        local timeStamp = lastOnName[inputUser:lower()]
                        if timeStamp then
                            chatbox.tell(user, inputUser.." last left SC3 on: "..textutils.formatTime(parseDateTime(timeStamp)), BOT_NAME)
                        else
                            chatbox.tell(user, "No data on "..inputUser..". Maybe they opted out.", BOT_NAME)
                        end
                    end
                else
                    chatbox.tell(user, "Tracks when a user last left from SC3. Usage: '\\seen lakeontario'. Opt out with '\\seen opt-out'.", BOT_NAME)
                end
            end
        end
    end,
    -- write if server shutdown imminent
    function ()
        while true do
            os.pullEvent("server_restart_scheduled")
            writeToFile()
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
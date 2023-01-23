local BOT_NAME = "last-left"
local OPT_OUT_PATH = "last-left/opt_out"
local TS_PATH = "last-left/ts"
local excluded = {}
local lastOn = {}
local timer = nil
local TS_PATTERN = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)%.(%d+)"

--helper functions
local function writeToFile()
    local ts = fs.open(TS_PATH, "w")
    for k,v in pairs(lastOn) do
        ts.write(k.."|"..v)
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
            local user, time = splitString(line, "|")
            lastOn[user] = time
        end
    end
    last.close()
end


parallel.waitForAny(
    --wait for leave event
    function ()
        while true do 
            local event, user, data = os.pullEvent("leave")
            if not excluded[user:lower()] then
                lastOn[user:lower()] = data.time
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
            if command == "last-left" then
                if #args > 0 then
                    if args[1] == "opt-out" then
                        local opt = fs.open(OPT_OUT_PATH, "a")
                        opt.write(user:lower())
                        opt.close()
                    else
                        local inputUser = args[1]
                        local timeStamp = lastOn[inputUser:lower()]
                        if timeStamp then
                            local xYear, xMonth, xDay, xHour, xMinute,
                                xSeconds, xMill, xOffset = timeStamp:match(TS_PATTERN)
                            local convertedTimestamp = os.time({year = xYear, month = xMonth,
                                day = xDay, hour = xHour, min = xMinute, sec = xSeconds})
                            chatbox.tell(user, inputUser.." last left SC3 on: "..convertedTimestamp, BOT_NAME)
                        else
                            chatbox.tell(user, "No data on "..inputUser..". Maybe they opted out.", BOT_NAME)
                        end
                    end
                else
                    chatbox.tell(user, "Tracks when a user last left from SC3. Usage: '\\last-left informer'. Opt out with '\\last-left opt-out'.", BOT_NAME)
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
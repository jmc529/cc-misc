local RESPECT_BOT = "respects"
local OPT_OUT_PATH = "respects/opt_out"
local RESPECTED_PATH = "respects/respected"
local websocket = http.websocket("wss://chat.sc3.io/v2/3101b983-1fb7-4a1f-9ab0-a99412a8c292")
local hello, ok = websocket.receive()
local respected = {}
local excluded = {}
local lastDead = nil
local deathTimer = nil

-- helper functions
local function writeToFile()
    local rd = fs.open(RESPECTED_PATH, "w")
    for k,v in pairs(respected) do
        rd.writeLine(k.."|"..v.name.."|"..v.fReceived)
    end
    rd.close()
end

local function splitString(s, sep)
    local t = {}
    for slice in string.gmatch(s, "([^" .. sep .. "]+)") do
        table.insert(t, slice)
    end
    return unpack(t)
end

local function loadRespects()
    -- load excluded
    if fs.exists(OPT_OUT_PATH) then
        local opt = fs.open(OPT_OUT_PATH, "r")
        while true do
            local line = opt.readLine()
            if not line then break end
            excluded[line] = true
        end
        opt.close()
    end

    --load table
    if fs.exists(RESPECTED_PATH) then
        local resp = fs.open(RESPECTED_PATH, "r")
        while true do
            local line = resp.readLine()
            if not line then
                break
            else
                local id, user, fs = splitString(line, "|")
                respected[id] = {name=user, fRecieved = fs}
            end
        end
        resp.close()
    end
end

parallel.waitForAny(
    function ()
        while true do
            local packet, ok = websocket.receive()
            packet = textutils.unserializeJSON(packet)
            if packet.type and packet.type == "event" then
                if packet.event == "death" then
                    lastDead = {["id"] = packet.user.uuid, ["name"] = packet.user.name}
                    deathTimer = os.startTimer(30)
                elseif packet.event == "command" then
                    if packet.ownerOnly and packet.command == RESPECT_BOT then
                        if packet.args[1] "opt-out" then
                            local opt = fs.open(OPT_OUT_PATH, "a")
                            excluded[packet.user.uuid] = true
                            opt.writeLine(packet.user.uuid)
                            opt.close()
                        else
                            chatbox.tell(user, "Press F to pay respects. Opt out with '\\"..RESPECT_BOT.." opt-out'", RESPECT_BOT)
                        end
                    end
                elseif lastDead and packet.event == "chat_ingame" then
                    if not excluded[packet.user.uuid] and packet.text:lower() == "f" then
                        chatbox.tell(packet.user.name, "You paid your respects to "..lastDead.name, RESPECT_BOT)
                        local currRespect = respected[lastDead.uuid].fReceived or 0
                        respected[lastDead.uuid] = {["name"] = lastDead.name, ["fReceived"] = currRespect + 1}
                        writeToFile()
                    end
                end
            end
        end
    end,
    -- remove lastDead
    function ()
        while true do
            local e, id = os.pullEvent("timer")
            if id == deathTimer then lastDead = nil end
        end
    end
)
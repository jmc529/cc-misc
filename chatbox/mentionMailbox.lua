local BOT_NAME = "i-afk"
local OPT_OUT_PATH = "afk/opt_out"
local MESSAGES_PATH = "afk/messages"
local excluded = {}

if fs.exists(OPT_OUT_PATH) then
    local opt = fs.open(OPT_OUT_PATH, "r")
    while true do
        local line = opt.readLine()
        if not line then break end
        excluded[line] = true
    end
    opt.close()
end

parallel.waitForAny(
    function ()
        while true do
            local event, user, message, data, time = os.pullEvent("chat")
            if message:find("informer") then
                if not excluded[user:lower()] then
                    chatbox.tell(user, "Informer is AFK right now. This mention has been recorded and they will see it when they return. Contact @Josee if you need faster response time.", BOT_NAME)
                    local m = fs.open(MESSAGES_PATH, "a")
                    m.write(time.."|"..message)
                    m.close()
                end
            end
        end        
    end,
    function ()
        while true do
            
            local event, user, command, args = os.pullEvent("command")
            if command and #args > 1 then
                local opt = fs.open(OPT_OUT_PATH, "a")
                opt.write(user:lower())
                opt.close()
            else
                chatbox.tell(user, "Informer's AFK chatbot. Mentions shown to them upon return. Opt out with '\\i-afk opt-out'", BOT_NAME)
            end
        end
    end
)
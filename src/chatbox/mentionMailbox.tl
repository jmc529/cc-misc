-- Records in-game mentions of a player while they are away and tells the
-- sender they are AFK. Players can opt out of the reply.

local os = _G.os as ccos

local BOT_NAME = "lake-afk"
local WATCH_FOR = "lakeontario"
local OPT_OUT_PATH = "afk/opt_out"
local MESSAGES_PATH = "afk/messages"
local AFK_REPLY = WATCH_FOR .. " is AFK right now. This mention has been recorded and they will see it when they return. Contact on discord if you need faster response time."
local HELP_REPLY = WATCH_FOR .. "'s AFK chatbot. Mentions shown to them upon return. Opt out with '\\" .. BOT_NAME .. " opt-out'"

local excluded: {string: boolean} = {}

local function loadExcluded()
   if not fs.exists(OPT_OUT_PATH) then return end
   local opt = fs.open(OPT_OUT_PATH, "r")
   while true do
      local line = opt.readLine()
      if not line then break end
      excluded[line] = true
   end
   opt.close()
end

local function optOut(user: string)
   local name = user:lower()
   excluded[name] = true
   local opt = fs.open(OPT_OUT_PATH, "a")
   -- Written a line at a time: `write` left every name on one line, so the
   -- file read back as a single unmatchable entry.
   opt.writeLine(name)
   opt.close()
end

local function recordMention(user: string, message: string, time: string)
   local m = fs.open(MESSAGES_PATH, "a")
   local info = user .. "|" .. time .. "|" .. message
   m.writeLine(info)
   m.close()
   print(info)
end

local function watchChat()
   while true do
      local _, user, message, data = os.pullEvent("chat_ingame")
      local sender = user as string
      if (message as string):find(WATCH_FOR) and not excluded[sender:lower()] then
         chatbox.tell(sender, AFK_REPLY, BOT_NAME)
         recordMention(sender, message as string, (data as chatbox.ChatEvent).time)
      end
   end
end

local function watchCommands()
   while true do
      local _, user, command, args = os.pullEvent("command")
      if command as string == BOT_NAME then
         if (args as {string})[1] == "opt-out" then
            optOut(user as string)
         else
            chatbox.tell(user as string, HELP_REPLY, BOT_NAME)
         end
      end
   end
end

loadExcluded()
parallel.waitForAny(watchChat, watchCommands)

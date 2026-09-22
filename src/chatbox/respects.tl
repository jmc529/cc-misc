-- Lets players pay respects with "F" after somebody dies, and keeps a tally of
-- how many each player has received.

local os = _G.os as ccos

local RESPECT_BOT = "respects"
local OPT_OUT_PATH = "respects/opt_out"
local RESPECTED_PATH = "respects/respected"
local CHAT_URL = "wss://chat.sc3.io/v2/3101b983-1fb7-4a1f-9ab0-a99412a8c292"
-- How long after a death players can still pay their respects.
local MOURNING_PERIOD = 30

local record Respect
   name: string
   fReceived: integer
end

local record Deceased
   uuid: string
   name: string
end

local respected: {string: Respect} = {}
local excluded: {string: boolean} = {}
local lastDead: Deceased = nil
local deathTimer: integer = nil

local function splitString(s: string, sep: string): {string}
   local parts: {string} = {}
   for slice in s:gmatch("([^" .. sep .. "]+)") do
      parts[#parts + 1] = slice
   end
   return parts
end

local function writeToFile()
   -- `fs` used to be shadowed by a local in the loader below, so this wrote
   -- through whatever that happened to be.
   local rd = fs.open(RESPECTED_PATH, "w")
   for uuid, respect in pairs(respected) do
      rd.writeLine(uuid .. "|" .. respect.name .. "|" .. tostring(respect.fReceived))
   end
   rd.close()
end

local function loadRespects()
   if fs.exists(OPT_OUT_PATH) then
      local opt = fs.open(OPT_OUT_PATH, "r")
      while true do
         local line = opt.readLine()
         if not line then break end
         excluded[line] = true
      end
      opt.close()
   end

   if fs.exists(RESPECTED_PATH) then
      local resp = fs.open(RESPECTED_PATH, "r")
      while true do
         local line = resp.readLine()
         if not line then break end
         local fields = splitString(line, "|")
         local uuid, name, count = fields[1], fields[2], fields[3]
         if uuid ~= nil then
            respected[uuid] = { name = name, fReceived = math.floor(tonumber(count) or 0) as integer }
         end
      end
      resp.close()
   end
end

local function optOut(uuid: string)
   excluded[uuid] = true
   local opt = fs.open(OPT_OUT_PATH, "a")
   opt.writeLine(uuid)
   opt.close()
end

local function payRespects(mourner: sc3.User)
   local grave = respected[lastDead.uuid] or { name = lastDead.name, fReceived = 0 }
   grave.name = lastDead.name
   grave.fReceived = grave.fReceived + 1
   respected[lastDead.uuid] = grave
   chatbox.tell(mourner.name, "You paid your respects to " .. lastDead.name, RESPECT_BOT)
   writeToFile()
end

local function handleCommand(packet: sc3.Packet)
   if not packet.ownerOnly or packet.command ~= RESPECT_BOT then return end
   if packet.args ~= nil and packet.args[1] == "opt-out" then
      optOut(packet.user.uuid)
   else
      chatbox.tell(packet.user.name,
         "Press F to pay respects. Opt out with '\\" .. RESPECT_BOT .. " opt-out'",
         RESPECT_BOT)
   end
end

local function watchChat(websocket: http.Websocket)
   while true do
      local message = websocket.receive()
      local packet = textutils.unserializeJSON(message) as sc3.Packet
      if packet ~= nil and packet.type == "event" then
         if packet.event == "death" then
            lastDead = { uuid = packet.user.uuid, name = packet.user.name }
            deathTimer = os.startTimer(MOURNING_PERIOD)
         elseif packet.event == "command" then
            handleCommand(packet)
         elseif lastDead ~= nil and packet.event == "chat_ingame" then
            if not excluded[packet.user.uuid] and packet.text:lower() == "f" then
               payRespects(packet.user)
            end
         end
      end
   end
end

-- Respects can only be paid for MOURNING_PERIOD seconds after a death.
local function expireLastDead()
   while true do
      local _, id = os.pullEvent("timer")
      if id as integer == deathTimer then lastDead = nil end
   end
end

local websocket = http.websocket(CHAT_URL)
if websocket == nil then
   error("Could not connect to " .. CHAT_URL, 0)
end
websocket.receive() -- the server's hello packet

loadRespects()
parallel.waitForAny(function() watchChat(websocket) end, expireLastDead)

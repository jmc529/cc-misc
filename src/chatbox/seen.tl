-- Tracks when each player was last seen leaving the server and shows the list
-- on a monitor, most recent last.

local os = _G.os as ccos

local TS_PATH = "seen/ts"
local MONITOR_NAME = "monitor_430"
local CHAT_URL = "wss://chat.sc3.io/v2/3101b983-1fb7-4a1f-9ab0-a99412a8c292"
-- Hours to add to the timestamps the server sends, which are UTC.
local UTC_OFFSET = -5
-- Writes are batched: a wave of leave events at restart would otherwise
-- rewrite the file once per player.
local WRITE_DELAY = 60

local record Seen
   uuid: string
   name: string
   ts: string
end

local lastOnID: {string: Seen} = {}
local leftTimer: integer = nil

local function splitString(s: string, sep: string): {string}
   local parts: {string} = {}
   for slice in s:gmatch("([^" .. sep .. "]+)") do
      parts[#parts + 1] = slice
   end
   return parts
end

-- Turns an ISO 8601 timestamp into the table `os.time` expects.
local function parseDateTime(str: string, offsetHours?: number): {string: integer}
   local Y, M, D = str:match("^(%d-)[-](%d-)[-](%d-)T")
   local h, m, s = str:match("T(%d-)[:](%d-)[:](%d-)[-+Z]")
   return {
      year = math.floor(tonumber(Y) or 1),
      month = math.floor(tonumber(M) or 1),
      day = math.floor(tonumber(D) or 1),
      hour = math.floor((tonumber(h) or 1) + (offsetHours or 0)),
      min = math.floor(tonumber(m) or 0),
      sec = math.floor(tonumber(s) or 0),
   }
end

-- Most recently seen last.
local function sortedEntries(): {Seen}
   local entries: {Seen} = {}
   for _, seen in pairs(lastOnID) do
      entries[#entries + 1] = seen
   end
   -- `table.sort` was previously called on `lastOnID` itself, which is keyed by
   -- uuid and so has no array part for sort to touch.
   table.sort(entries, function(a: Seen, b: Seen): boolean
      return os.time(parseDateTime(a.ts)) < os.time(parseDateTime(b.ts))
   end)
   return entries
end

-- "name        11/02/24|4:05 PM", padded out to the monitor's width.
local function formatTime(name: string, ts: string, width: integer): string
   local time = parseDateTime(ts, UTC_OFFSET)
   local stamp = time.month .. "/" .. time.day .. "/" .. (time.year % 100)
      .. "|" .. textutils.formatTime(time.hour + (time.min / 60) + (time.sec / 3600), true)

   local gap = width - 1 - #(name .. stamp)
   if gap > 0 then
      return name .. (" "):rep(gap) .. stamp
   end
   return name:sub(1, math.max(#name + gap, 1)) .. stamp
end

local function render()
   local monitor = peripheral.wrap(MONITOR_NAME) as peripherals.Monitor
   if monitor == nil then return end

   local width, height = monitor.getSize()
   monitor.clear()
   local entries = sortedEntries()
   local row = 1
   for i = math.max(#entries - height + 1, 1), #entries do
      monitor.setCursorPos(1, row)
      monitor.write(formatTime(entries[i].name, entries[i].ts, width))
      row = row + 1
   end
end

local function writeToFile()
   local ts = fs.open(TS_PATH, "w")
   for _, seen in ipairs(sortedEntries()) do
      ts.writeLine(seen.uuid .. "|" .. seen.name .. "|" .. seen.ts)
   end
   ts.close()
   render()
end

local function loadSeen()
   if not fs.exists(TS_PATH) then return end
   local last = fs.open(TS_PATH, "r")
   while true do
      local line = last.readLine()
      if not line then break end
      local fields = splitString(line, "|")
      local uuid, name, time = fields[1], fields[2], fields[3]
      if uuid ~= nil and name ~= nil and time ~= nil then
         lastOnID[uuid] = { uuid = uuid, name = name, ts = time }
      end
   end
   last.close()
end

local function watchLeaves(websocket: http.Websocket)
   while true do
      local message = websocket.receive()
      local packet = textutils.unserializeJSON(message) as sc3.Packet
      if packet ~= nil and packet.type == "event" and packet.event == "leave" then
         lastOnID[packet.user.uuid] = { uuid = packet.user.uuid, name = packet.user.name, ts = packet.time }
         if leftTimer ~= nil then
            os.cancelTimer(leftTimer)
         end
         leftTimer = os.startTimer(WRITE_DELAY)
      end
   end
end

local function writeOnShutdown(websocket: http.Websocket)
   while true do
      os.pullEvent("server_restart_scheduled")
      writeToFile()
      websocket.close()
   end
end

local function writeWhenQueued()
   while true do
      local _, id = os.pullEvent("timer")
      if id as integer == leftTimer then writeToFile() end
   end
end

local websocket = http.websocket(CHAT_URL)
if websocket == nil then
   error("Could not connect to " .. CHAT_URL, 0)
end
websocket.receive() -- the server's hello packet

loadSeen()
render()
parallel.waitForAny(
   function() watchLeaves(websocket) end,
   function() writeOnShutdown(websocket) end,
   writeWhenQueued)

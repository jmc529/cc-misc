local modules = peripheral.find("neuralInterface")
if not modules.hasModule("plethora:glasses") then error("Must have overlay glasses", 0) end

local canvas = modules.canvas()
local width,height = canvas.getSize()
local half = width/2
canvas.clear()

local url = "http://tycho.usno.navy.mil/cgi-bin/timer.pl" --pulls time from navy site
local time_S = string.sub(http.get(url).readAll(), 217,227) --grabs relative html source

local hour_n = tonumber(string.sub(time_S, 1,2))
local min_n = tonumber(string.sub(time_S, 4,5))
local sec_n = tonumber(string.sub(time_S, 7,8))

if (string.sub(time_S, 10,11) == "PM") then
  hour_n = hour_n + 12
end


local time_n_s = (hour_n*3600)+(min_n*60)+sec_n -- maybe subtract or add something for better calibration

local init = os.clock()

while true do
    local igTime = textutils.formatTime(os.time())
    local item2 = canvas.addText({half-(string.len(igTime)/2),10}, igTime)
    local current = os.clock()
    local sub = current - init -- the in game "pendulum"
    local total = ((time_n_s + sub)/3600) % 24
    local time = textutils.formatTime(total)
    local item = canvas.addText({half-string.len(time)/2,20}, time)
    sleep(0)
    item.remove()
    item2.remove()
end
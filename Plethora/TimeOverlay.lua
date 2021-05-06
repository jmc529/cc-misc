modules = peripheral.find("neuralInterface")
if not modules.hasModule("plethora:glasses") then error("Must have overlay glasses", 0) end

canvas = modules.canvas()
width,height = canvas.getSize()
half = width/2
canvas.clear() 

url = "http://tycho.usno.navy.mil/cgi-bin/timer.pl" --pulls time from navy site
time_S = string.sub(http.get(url).readAll(), 217,227) --grabs relative html source

hour_n = tonumber(string.sub(time_S, 1,2)) 
min_n = tonumber(string.sub(time_S, 4,5))
sec_n = tonumber(string.sub(time_S, 7,8))

if (string.sub(time_S, 10,11) == "PM") then
  hour_n = hour_n + 12
end


time_n_s = (hour_n*3600)+(min_n*60)+sec_n -- maybe subtract or add something for better calibration

init = os.clock()

while true do    
    igTime = textutils.formatTime(os.time())   
    item2 = canvas.addText({half-(string.len(igTime)/2),10}, igTime)
    curr = os.clock()
    sub = curr - init -- the in game "pendulum"
    total = ((time_n_s + sub)/3600) % 24
    time = textutils.formatTime(total)
    item = canvas.addText({half-string.len(time)/2,20}, time)
    sleep(0)
    item.remove()
    item2.remove()
end
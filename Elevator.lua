--[[
  An elevator making use of slime blocks, sticky pistons, and turtles. 
  [Caveat: can only touch blocks not affected by slime blocks, suggested: leaf blocks]
  Configuration: 
  [ ][T]
  [S][P]
  [P][S]
  [T][ ]
]]--



---Top turtle--
--edit nunmbers, they must relate to the other turtle
local selfChannel = 111
local turtChannel = 112

modem = peripheral.wrap("left")
modem.open(selfChannel)

while true do
  --ping event to determine distance 
  local e,s,sc,reply,count,d = os.pullEvent("modem_message")
  if count == "ping" then 
    modem.transimit(rc, selfChannel, "ping")
  elseif count > 0 then
    while count > 0 do
      --errors if there are obstructions else moves the turtle
      if turtle.detectUp() then 
        modem.transmit(reply,selfChannel,"FailureTop")
        modem.close(selfChannel)
        error("Turtle is obstructed.")
      else turtle.up() end
      --annoying but usable communication based method of moving
      --on == active state (moving/pistons firing) off == inactive state (stopped/no firing)
      modem.transmit(turtChannel,selfChannel,"On")
      repeat e,s,sc,rc,m,d = os.pullEvent("modem_message") until(m == "On")
      redstone.setOutput("bottom", true) 
      os.sleep(.2)
      modem.transmit(turtChannel,selfChannel,"Off")
      repeat e,s,sc,rc,m,d = os.pullEvent("modem_message") until(m == "Off")
      os.sleep(.2)
      redstone.setOutput("bottom", false)
      os.sleep(.2)
      modem.transmit(turtChannel,selfChannel,"Up")
      repeat e,s,sc,rc,m,d = os.pullEvent("modem_message") until(m == "Up")
      count = count - 1
    end
  elseif count < 0 then
    while count < 0 do
      --reciprical movement for previous while loop
      repeat e,s,sc,rc,m,d = os.pullEvent("modem_message") until(m == "On")
      redstone.setOutput("bottom", true)
      modem.transmit(turtChannel,selfChannel,"On")
      repeat e,s,sc,rc,m,d = os.pullEvent("modem_message") until(m == "Off")
      redstone.setOutput("bottom", false)
      modem.transmit(turtChannel,selfChannel,"Off")
      repeat e,s,sc,rc,m,d = os.pullEvent("modem_message") until(m == "Down")
      if turtle.detectDown() then
        modem.transmit(reply,selfChannel,"FailureTop")
        modem.close(selfChannel)
        error("Turtle is obstructed.")   
      else 
        turtle.down()
        modem.transmit(turtChannel,selfChannel,"Down")    
      end
      count = count + 1
    end
  end
  modem.transmit(reply,selfChannel,"Success") --unless it errors this always transmits
end

--Bottom turtle--
--edit nunmbers, they must relate to the other turtle
--look at previous comments for description.
local selfChannel = 112
local turtChannel = 111

modem = peripheral.wrap("left")
modem.open(selfChannel)

while true do
  local e,s,sc,reply,count,d = os.pullEvent("modem_message")
  if count == "ping" then 
    modem.transimit(rc, selfChannel, "ping")
  elseif count > 0 then
    while count > 0 do
      repeat e,s,sc,rc,m,d = os.pullEvent("modem_message") until(m == "On")
      redstone.setOutput("top", true)
      modem.transmit(turtChannel,selfChannel,"On")
      repeat e,s,sc,rc,m,d = os.pullEvent("modem_message") until(m == "Off")
      redstone.setOutput("top", false)
      modem.transmit(turtChannel,selfChannel,"Off")
      repeat e,s,sc,rc,m,d = os.pullEvent("modem_message") until(m == "Up")
      if turtle.detectUp() then 
        modem.transmit(reply,selfChannel,"FailureBottom")
        modem.close(selfChannel)
        error("Turtle is obstructed.")
      else 
        turtle.up()
        modem.transmit(turtChannel,selfChannel,"Up")    
      end
      count = count - 1
    end
    modem.transmit(reply,selfChannel,"Success")
  elseif count < 0 then
      while count < 0 do
      if turtle.detectDown() then
        modem.transmit(reply,selfChannel,"FailureBottom")
        modem.close(selfChannel)
        error("Turtle is obstructed.")   
      else turtle.down() end
      modem.transmit(turtChannel,selfChannel,"On")
      repeat e,s,sc,rc,m,d = os.pullEvent("modem_message") until(m == "On")
      redstone.setOutput("top", true) 
      os.sleep(.2)
      modem.transmit(turtChannel,selfChannel,"Off")
      repeat e,s,sc,rc,m,d = os.pullEvent("modem_message") until(m == "Off")
      os.sleep(.2)
      redstone.setOutput("top", false)
      os.sleep(.2)
      modem.transmit(turtChannel,selfChannel,"Down")
      repeat e,s,sc,rc,m,d = os.pullEvent("modem_message") until(m == "Down")
      count = count + 1
    end
    modem.transmit(reply,selfChannel,"Success")
  end
end

---Computer---
tArgs = {...}

---EDIT these numbers---
local maxFlr = 5
local flrDist = 6 --distance b/w two floors
local turtDist = 4 --distance b/w two turtles
local channels = {turt1 = 111, turt2 = 112} --channels for turtles
local channel = 222
--not these--
local currFlr = 1
local nextFlr = 1
local dist = 0
local modem = peripheral.find("wireless_modem")

modem.open(channel)

--grabs current floor
local f = fs.open("utility/.floor", r)
if f then
  currFlr = textutils.unserialize(f.readLine())
end
f.close()

--uses law of cosines and some basic trig to find the location of the user based upon the dist
local function call()
  local dists = {}
  --obtaining dist b/w turtles and user's computer
  for k,v in ipairs(channels) do
    modem.transmit(v,channel,"ping")
    local e,s,sc,rc,m,d = os.pullEvent("modem_message")
    dists[k] = d
  end
  --law of cosines
  local A = math.acos((math.pow(dists[turt1],2)+math.pow(dists[turt2],2)-math.pow(turtDist,2))/(2*dists[turt1]*dists[turt2]))
  local C = math.acos((math.pow(dists[turt1],2)+math.pow(turtDist,2)-math.pow(dists[turt2],2))/(2*dists[turt1]*turtDist))
  local G = math.rad(math.pi - A - C)
  --determine distance to be traveled
  local sign = (dists[turt1] > dists[turt2]) and -1 or 1
  dist = sign*math.ceil((turtDist + dists[turt2]*math.sin(G))/flrDist) --possible issues: height displacement from character, the ceil function itself, C might need to be changed to B if the user is above the system
  --writing the current floor to a file
  local f = fs.open("utility/.floor", w)
  local currFlr = dist + currFlr
  f.writeLine(textutils.serialize(currFlr))
  f.close()
  modem.transmit(channels[turt1],channel,(dist*flrDist))    
end

--checks to see if the user is within bounds
if #tArgs ~= 1 then
  print("Usage: <filename> <\"call\"/floornumber>")
  return
elseif tArg[1] == "call" then
  call()
  return
elseif tonumber(tArgs[1]) > maxFlr then
  print("Your complex only has "..maxFlr.." floors.")
  return
else
  nextFlr = tonumber(tArgs[1])
end

--cacluates needed distance the machine needs to move
if currFlr == nextFlr then 
  print("You're on floor "..nextFlr.."... that was fast...")
  return
elseif currFlr > nextFlr then
  dist = (currFlr - nextFlr) * -1 * flrDist 
else
  dist = (nextFlr - currFlr) * flrDist 
end
modem.tranmit(channels[turt1],channel, dist)

local e,s,sc,rc,m,d = os.pullEvent("modem_message")
modem.close(222)
if (m == "FailureTop") then
  error("Top turtle seems to be obstructed or out of fuel.")
elseif (m == "FailureBottom") then 
  error("Bottom turtle seems to be obstructed or out of fuel.")
elseif (m == "Success") then
  print(m)
  local f = fs.open("utility/.floor", w)
  f.writeLine(textutils.serialize(nextFlr))
  f.close()
else
  error("Issue unknown.")
end

print("Welcome to floor:"..nextFlr)
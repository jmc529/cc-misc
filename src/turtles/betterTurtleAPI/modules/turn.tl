-- Cardinal direction handling for betterTurtleAPI.

local state = require("modules.state")

local record turn
   calibrate: function()
   getDirection: function(): string
   toCardinal: function(cardinal: string)
   spin: function(direction: string | integer, count?: integer)
   north: function()
   east: function()
   south: function()
   west: function()
end

local CARDINALS: {string: integer} = {
   ["north"] = 0,
   ["east"] = 1,
   ["south"] = 2,
   ["west"] = 3,
}
local NAMES: {integer: string} = { [0] = "north", [1] = "east", [2] = "south", [3] = "west" }

local function isLeft(direction: string | integer): boolean
   if direction is string then
      return direction:lower() == "left"
   end
   return direction == -1
end

local function isRight(direction: string | integer): boolean
   if direction is string then
      return direction:lower() == "right"
   end
   return direction == 1
end

function turn.getDirection(): string
   return NAMES[state.direction % 4]
end

function turn.spin(direction: string | integer, count?: integer)
   local remaining = count or 1
   if isLeft(direction) then
      while remaining > 0 do
         turtle.turnLeft()
         state.direction = state.direction - 1
         remaining = remaining - 1
      end
   elseif isRight(direction) then
      while remaining > 0 do
         turtle.turnRight()
         state.direction = state.direction + 1
         remaining = remaining - 1
      end
   end
end

-- Turns to `target` the short way round. The old per-cardinal implementations
-- each open-coded this and `east()` got it wrong, spinning left a negative
-- number of times (i.e. not at all) when already facing north.
local function face(target: integer)
   local delta = (target - (state.direction % 4)) % 4
   if delta == 0 then
      return
   elseif delta == 3 then
      turn.spin("left")
   else
      turn.spin("right", delta)
   end
end

function turn.north() face(CARDINALS["north"]) end
function turn.east() face(CARDINALS["east"]) end
function turn.south() face(CARDINALS["south"]) end
function turn.west() face(CARDINALS["west"]) end

function turn.toCardinal(cardinal: string)
   local target = CARDINALS[cardinal:lower()]
   if target ~= nil then
      face(target)
   end
end

-- Asks the player where the turtle is when there is no gps constellation in
-- range, otherwise works the heading out by stepping forward and back.
local function calibrateByHand()
   state.gpsMode = false
   print("Please enter in the exact coordinates of the turtle\nX:")
   local x = tonumber(read())
   print("\nY:")
   local y = tonumber(read())
   print("\nZ:")
   local z = tonumber(read())
   if x == nil or y == nil or z == nil then
      print("Coordinates must be numbers.")
      return turn.calibrate()
   end
   state.position = vector.new(x, y, z)

   print("Please enter the direction the turtle is facing <N,E,W,S>:")
   local heading = read():upper()
   local headings: {string: integer} = { ["N"] = 0, ["E"] = 1, ["S"] = 2, ["W"] = 3 }
   local direction = headings[heading]
   if direction == nil then
      return turn.calibrate()
   end
   state.direction = direction
end

function turn.calibrate()
   local x, y, z = gps.locate(5)
   if x == nil then
      return calibrateByHand()
   end

   local fuel = turtle.getFuelLevel()
   if fuel is integer and fuel < 1 then
      error("Please supply your turtle with fuel for gps calibration.")
   end

   local origin = vector.new(x, y as number, z as number)
   state.position = origin
   if not turtle.forward() then
      error("The turtle needs a free block in front of it to calibrate.")
   end
   local ahead = vector.new(gps.locate(5))
   turtle.back()

   local step = ahead - origin
   if step.z == -1 then
      state.direction = 0
   elseif step.x == 1 then
      state.direction = 1
   elseif step.z == 1 then
      state.direction = 2
   elseif step.x == -1 then
      state.direction = 3
   end
end

return turn

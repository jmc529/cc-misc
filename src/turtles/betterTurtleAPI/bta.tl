--[[
A robust turtle API for computercraft that improves upon functions and adds new ones.
Pastebin: MdD051uF
    Functions:
        getPosition() returns the turtle's position as a vector
        boxTo(destinationVector[, fn]) moves to every location between two coordinates
        goTo(vector[, fn]) moves the turtle to a specific vector
        calibrate() works out where the turtle is and which way it faces
        refuel() checks inventory for fuel
    Packages:
        move.
            move(direction[, fn][, count]) multiple times, forward-back-up-down
            xMovement(distance[, fn]) moves the turtle along the x-axis
            yMovement(distance[, fn]) moves the turtle along the y-axis
            zMovement(distance[, fn]) moves the turtle along the z-axis
        turn.
            calibrate() to the cardinal direction
            north() (etc..) face the four cardinal directions
            spin(direction[, count]) multiple times
            toCardinal(str) face cardinal direction by user input
            getDirection() get current direction as a string value

Call calibrate() before moving, so the API knows where the turtle is and which
way it is pointing.

This API should be used with lua's require method

@author lakeontario
@date January 28th 2023
@version 0.2.0
]]--

local state = require("modules.state")
local turn = require("modules.turn")
local move = require("modules.move")

-- Burns whatever fuel is in the inventory, up to the turtle's fuel limit.
local function refuel(): boolean, integer
   local level = turtle.getFuelLevel()
   if level is string then
      -- "unlimited" on a fuel-less server; nothing to do.
      return true, math.huge as integer
   end

   local limit = turtle.getFuelLimit() as integer
   for slot = 1, 16 do
      turtle.select(slot)
      if turtle.refuel(0) then
         while (turtle.getFuelLevel() as integer) < limit and turtle.getItemCount(slot) > 0 do
            turtle.refuel(1)
         end
         return true, turtle.getFuelLevel() as integer
      end
   end

   return false, level
end

-- Returns the turtle's position as a vector, from gps where available and from
-- dead reckoning otherwise.
local function getPosition(): vector.Vector
   return state.locate()
end

local function arrived(destination: vector.Vector): boolean, vector.Vector
   local here = state.locate()
   if here.x == destination.x and here.y == destination.y and here.z == destination.z then
      return true
   end
   return false, destination
end

-- Moves the turtle to `destination`, applying `fn` at each step.
local function goTo(destination: vector.Vector, fn?: function()): boolean, vector.Vector
   local distance = destination - state.locate()

   move.yMovement(distance.y, fn)
   move.xMovement(distance.x, fn)
   move.zMovement(distance.z, fn)

   return arrived(destination)
end

-- Every coordinate of the box spanned by the turtle's position and
-- `destination`, ordered so that consecutive coordinates are always adjacent:
-- the turtle snakes along z, then along x, then climbs to the next layer.
local function boxCoordinates(from: vector.Vector, to: vector.Vector): {vector.Vector}
   local coordinates: {vector.Vector} = {}

   local yStep = to.y >= from.y and 1 or -1
   local xStep = to.x >= from.x and 1 or -1
   local zStep = to.z >= from.z and 1 or -1

   -- Reverse every other layer and every other row so that consecutive
   -- coordinates are always one block apart. `row` deliberately keeps counting
   -- across layers, so a layer starts on the z the previous one finished on.
   local layer = 0
   local row = 0
   for y = from.y, to.y, yStep do
      local xFirst = layer % 2 == 0 and from.x or to.x
      local xLast = layer % 2 == 0 and to.x or from.x
      for x = xFirst, xLast, layer % 2 == 0 and xStep or -xStep do
         local zFirst = row % 2 == 0 and from.z or to.z
         local zLast = row % 2 == 0 and to.z or from.z
         for z = zFirst, zLast, row % 2 == 0 and zStep or -zStep do
            coordinates[#coordinates + 1] = vector.new(x, y, z)
         end
         row = row + 1
      end
      layer = layer + 1
   end

   return coordinates
end

-- Moves the turtle to `destination`, hitting every coordinate in between.
local function boxTo(destination: vector.Vector, fn?: function()): boolean, vector.Vector
   for _, coordinate in ipairs(boxCoordinates(state.locate(), destination)) do
      goTo(coordinate, fn)
   end
   -- The sweep finishes on whichever corner the snake ends up at, so make a
   -- final trip to the destination itself.
   return goTo(destination)
end

return {
   calibrate = turn.calibrate,
   getPosition = getPosition,
   goTo = goTo,
   boxTo = boxTo,
   refuel = refuel,
   move = move,
   turn = turn,
}

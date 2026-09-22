-- Movement helpers for betterTurtleAPI.

local state = require("modules.state")
local turn = require("modules.turn")

local type Step = function(): boolean, string

local record move
   -- Callable as `move.move(direction, fn, count)`.
   move: function(direction: string | integer, fn?: function(), count?: integer): boolean, integer
   refuel: function(): boolean, integer
   xMovement: function(distance: number, fn?: function()): boolean, integer
   yMovement: function(distance: number, fn?: function()): boolean, integer
   zMovement: function(distance: number, fn?: function()): boolean, integer
end

local STEPS: {string: Step} = {
   ["forward"] = turtle.forward,
   ["back"] = turtle.back,
   ["up"] = turtle.up,
   ["down"] = turtle.down,
}
local BY_INDEX: {integer: string} = { "forward", "back", "up", "down" }

local function stepFor(direction: string | integer): Step
   if direction is string then
      return STEPS[direction:lower()]
   end
   local name = BY_INDEX[direction]
   return name ~= nil and STEPS[name] or nil
end

-- Moves `count` blocks in one direction, applying `fn` at each step.
-- Returns true when unimpeded, or false and the number of blocks left.
function move.move(direction: string | integer, fn?: function(), count?: integer): boolean, integer
   local remaining = count or 1
   local step = stepFor(direction)
   if step == nil then
      return false, remaining
   end

   if fn ~= nil then fn() end

   while remaining > 0 do
      if not step() then
         return false, remaining
      end
      remaining = remaining - 1
      if fn ~= nil then fn() end
   end
   return true, 0
end

-- Burns whatever fuel is in the inventory, up to the turtle's fuel limit.
function move.refuel(): boolean, integer
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

local function axisMovement(axis: string, distance: number, fn?: function(), before?: function()): boolean, integer
   if distance == 0 then
      return true, 0
   end
   if before ~= nil then before() end

   local blocks = math.floor(math.abs(distance)) as integer
   local direction = axis == "y" and (distance > 0 and "up" or "down") or "forward"
   local completed, remaining = move.move(direction, fn, blocks)
   local travelled = blocks - remaining
   state.translate(axis, distance > 0 and travelled or -travelled)
   return completed, remaining
end

function move.xMovement(distance: number, fn?: function()): boolean, integer
   return axisMovement("x", distance, fn, distance > 0 and turn.east or turn.west)
end

function move.yMovement(distance: number, fn?: function()): boolean, integer
   return axisMovement("y", distance, fn)
end

function move.zMovement(distance: number, fn?: function()): boolean, integer
   return axisMovement("z", distance, fn, distance > 0 and turn.south or turn.north)
end

return move

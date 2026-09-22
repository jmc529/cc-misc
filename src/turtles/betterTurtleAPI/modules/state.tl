-- Position and heading shared by the betterTurtleAPI modules.
--
-- `turn` and `move` used to read and write `position`, `currentDirection` and
-- `gpsMode`, which were locals of `bta.lua` and therefore invisible to them.
-- Holding that state in its own module gives every module the same instance.

local record state
   -- Cardinal heading: 0 north, 1 east, 2 south, 3 west.
   direction: integer
   position: vector.Vector
   -- False once the turtle is known to be out of range of a gps constellation,
   -- after which `position` is dead reckoned from the moves we make.
   gpsMode: boolean

   locate: function(): vector.Vector
   translate: function(axis: string, distance: number)
end

state.direction = 0
state.position = vector.new(0, 0, 0)
state.gpsMode = true

-- Refreshes `position` from gps when available, falling back to dead reckoning.
function state.locate(): vector.Vector
   if state.gpsMode then
      local x, y, z = gps.locate(5)
      if x ~= nil then
         state.position = vector.new(x, y as number, z as number)
      else
         state.gpsMode = false
      end
   end
   return state.position
end

function state.translate(axis: string, distance: number)
   local p = state.position
   if axis == "x" then
      state.position = vector.new(p.x + distance, p.y, p.z)
   elseif axis == "y" then
      state.position = vector.new(p.x, p.y + distance, p.z)
   else
      state.position = vector.new(p.x, p.y, p.z + distance)
   end
end

return state

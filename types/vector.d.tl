-- Type declarations for the CC:Tweaked `vector` API.
-- https://tweaked.cc/module/vector.html

local record vector
   record Vector
      x: number
      y: number
      z: number

      add: function(Vector, Vector): Vector
      sub: function(Vector, Vector): Vector
      mul: function(Vector, number): Vector
      div: function(Vector, number): Vector
      unm: function(Vector): Vector
      dot: function(Vector, Vector): number
      cross: function(Vector, Vector): Vector
      length: function(Vector): number
      normalize: function(Vector): Vector
      round: function(Vector, tolerance?: number): Vector
      tostring: function(Vector): string
      equals: function(Vector, Vector): boolean

      metamethod __add: function(Vector, Vector): Vector
      metamethod __sub: function(Vector, Vector): Vector
      metamethod __mul: function(Vector, number): Vector
      metamethod __div: function(Vector, number): Vector
      metamethod __unm: function(Vector): Vector
      metamethod __tostring: function(Vector): string
      metamethod __eq: function(Vector, Vector): boolean
   end

   new: function(x: number, y: number, z: number): Vector
end

return vector

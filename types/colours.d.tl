-- Type declarations for the CC:Tweaked `colours` API, the British spelling of
-- `colors`. It shares every field with `colors`, except that `gray` and
-- `lightGray` are spelled `grey` and `lightGrey`.
-- https://tweaked.cc/module/colours.html

local record colours
   white: integer
   orange: integer
   magenta: integer
   lightBlue: integer
   yellow: integer
   lime: integer
   pink: integer
   grey: integer
   lightGrey: integer
   cyan: integer
   purple: integer
   blue: integer
   brown: integer
   green: integer
   red: integer
   black: integer

   combine: function(...: integer): integer
   subtract: function(colours: integer, ...: integer): integer
   test: function(colours: integer, colour: integer): boolean
   packRGB: function(r: number, g: number, b: number): number
   unpackRGB: function(rgb: number): number, number, number
   rgb8: function(r: number, g: number, b: number): number
   rgb8: function(rgb: number): number, number, number
   toBlit: function(colour: integer): string
   fromBlit: function(hex: string): integer
end

return colours

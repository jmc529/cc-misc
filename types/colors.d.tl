-- Type declarations for the CC:Tweaked `colors` API.
-- https://tweaked.cc/module/colors.html

local record colors
   white: integer
   orange: integer
   magenta: integer
   lightBlue: integer
   yellow: integer
   lime: integer
   pink: integer
   gray: integer
   lightGray: integer
   cyan: integer
   purple: integer
   blue: integer
   brown: integer
   green: integer
   red: integer
   black: integer

   combine: function(...: integer): integer
   subtract: function(colors: integer, ...: integer): integer
   test: function(colors: integer, color: integer): boolean
   packRGB: function(r: number, g: number, b: number): number
   unpackRGB: function(rgb: number): number, number, number
   rgb8: function(r: number, g: number, b: number): number
   rgb8: function(rgb: number): number, number, number
   toBlit: function(color: integer): string
   fromBlit: function(hex: string): integer
end

return colors

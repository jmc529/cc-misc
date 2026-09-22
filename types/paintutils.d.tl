-- Type declarations for the CC:Tweaked `paintutils` API.
-- https://tweaked.cc/module/paintutils.html

local record paintutils
   -- An image is a list of rows, each of which is a list of colours.
   type Image = {{integer}}

   parseImage: function(image: string): Image
   loadImage: function(path: string): Image
   drawPixel: function(xPos: integer, yPos: integer, colour?: integer)
   drawLine: function(startX: integer, startY: integer, endX: integer, endY: integer, colour?: integer)
   drawBox: function(startX: integer, startY: integer, endX: integer, endY: integer, colour?: integer)
   drawFilledBox: function(startX: integer, startY: integer, endX: integer, endY: integer, colour?: integer)
   drawImage: function(image: Image, xPos: integer, yPos: integer)
end

return paintutils

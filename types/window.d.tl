-- Type declarations for the CC:Tweaked `window` API.
-- https://tweaked.cc/module/window.html

local termlib = require("types.term")

local record window
   record Window is termlib.Redirect
      getLine: function(y: integer): string, string, string
      setVisible: function(visible: boolean)
      isVisible: function(): boolean
      redraw: function()
      restoreCursor: function()
      getPosition: function(): integer, integer
      reposition: function(new_x: integer, new_y: integer, new_width?: integer, new_height?: integer, new_parent?: termlib.Redirect)
   end

   create: function(parent: termlib.Redirect, nX: integer, nY: integer, nWidth: integer, nHeight: integer, bStartVisible?: boolean): Window
end

return window

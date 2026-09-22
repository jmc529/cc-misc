-- Type declarations for the CC:Tweaked `term` API.
-- https://tweaked.cc/module/term.html

local record term
   -- A terminal object: anything that can be passed to `term.redirect`, such as
   -- a monitor peripheral or a window.
   interface Redirect
      write: function(text: string)
      scroll: function(y: integer)
      getCursorPos: function(): integer, integer
      setCursorPos: function(x: integer, y: integer)
      getCursorBlink: function(): boolean
      setCursorBlink: function(blink: boolean)
      getSize: function(): integer, integer
      clear: function()
      clearLine: function()
      getTextColour: function(): integer
      getTextColor: function(): integer
      setTextColour: function(colour: integer)
      setTextColor: function(color: integer)
      getBackgroundColour: function(): integer
      getBackgroundColor: function(): integer
      setBackgroundColour: function(colour: integer)
      setBackgroundColor: function(color: integer)
      isColour: function(): boolean
      isColor: function(): boolean
      blit: function(text: string, textColour: string, backgroundColour: string)
      setPaletteColour: function(index: integer, colour: number, g?: number, b?: number)
      setPaletteColor: function(index: integer, color: number, g?: number, b?: number)
      getPaletteColour: function(colour: integer): number, number, number
      getPaletteColor: function(color: integer): number, number, number
   end

   write: function(text: string)
   scroll: function(y: integer)
   getCursorPos: function(): integer, integer
   setCursorPos: function(x: integer, y: integer)
   getCursorBlink: function(): boolean
   setCursorBlink: function(blink: boolean)
   getSize: function(): integer, integer
   clear: function()
   clearLine: function()
   getTextColour: function(): integer
   getTextColor: function(): integer
   setTextColour: function(colour: integer)
   setTextColor: function(color: integer)
   getBackgroundColour: function(): integer
   getBackgroundColor: function(): integer
   setBackgroundColour: function(colour: integer)
   setBackgroundColor: function(color: integer)
   isColour: function(): boolean
   isColor: function(): boolean
   blit: function(text: string, textColour: string, backgroundColour: string)
   setPaletteColour: function(index: integer, colour: number, g?: number, b?: number)
   setPaletteColor: function(index: integer, color: number, g?: number, b?: number)
   getPaletteColour: function(colour: integer): number, number, number
   getPaletteColor: function(color: integer): number, number, number

   nativePaletteColour: function(colour: integer): number, number, number
   nativePaletteColor: function(color: integer): number, number, number

   redirect: function(target: Redirect): Redirect
   current: function(): Redirect
   native: function(): Redirect
end

return term

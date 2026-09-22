-- Type declarations for the CC:Tweaked `turtle` API.
-- https://tweaked.cc/module/turtle.html
--
-- Almost every action returns `true` on success, or `false` plus a reason on
-- failure, hence the repeated `boolean, string` results.

local peripheralslib = require("types.peripherals")

local record turtle
   record BlockInfo
      name: string
      state: {string: any}
      tags: {string: boolean}
   end

   forward: function(): boolean, string
   back: function(): boolean, string
   up: function(): boolean, string
   down: function(): boolean, string
   turnLeft: function(): boolean, string
   turnRight: function(): boolean, string

   -- `side` selects which equipped tool to use: "left" or "right".
   dig: function(side?: string): boolean, string
   digUp: function(side?: string): boolean, string
   digDown: function(side?: string): boolean, string

   place: function(text?: string): boolean, string
   placeUp: function(text?: string): boolean, string
   placeDown: function(text?: string): boolean, string

   drop: function(count?: integer): boolean, string
   dropUp: function(count?: integer): boolean, string
   dropDown: function(count?: integer): boolean, string

   suck: function(count?: integer): boolean, string
   suckUp: function(count?: integer): boolean, string
   suckDown: function(count?: integer): boolean, string

   select: function(slot: integer): boolean
   getSelectedSlot: function(): integer
   getItemCount: function(slot?: integer): integer
   getItemSpace: function(slot?: integer): integer
   getItemDetail: function(slot?: integer, detailed?: boolean): peripheralslib.ItemDetail

   detect: function(): boolean
   detectUp: function(): boolean
   detectDown: function(): boolean

   compare: function(): boolean
   compareUp: function(): boolean
   compareDown: function(): boolean
   compareTo: function(slot: integer): boolean

   -- Returns whether a block is there, and either its details or a message.
   inspect: function(): boolean, BlockInfo | string
   inspectUp: function(): boolean, BlockInfo | string
   inspectDown: function(): boolean, BlockInfo | string

   attack: function(side?: string): boolean, string
   attackUp: function(side?: string): boolean, string
   attackDown: function(side?: string): boolean, string

   transferTo: function(slot: integer, count?: integer): boolean

   getFuelLevel: function(): integer | string
   getFuelLimit: function(): integer | string
   refuel: function(count?: integer): boolean, string

   equipLeft: function(): boolean, string
   equipRight: function(): boolean, string
   getEquippedLeft: function(): peripheralslib.ItemDetail
   getEquippedRight: function(): peripheralslib.ItemDetail

   -- Only available when a crafting table is equipped.
   craft: function(limit?: integer): boolean, string
end

return turtle

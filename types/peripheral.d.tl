-- Type declarations for the CC:Tweaked `peripheral` API.
-- https://tweaked.cc/module/peripheral.html
--
-- Wrapped peripherals are dynamic by nature, so `wrap`, `find` and `getMethods`
-- return the loose `Peripheral` map type. Cast it to one of the records in
-- `types/peripherals/` (or `types/plethora.d.tl`) to get a checked API:
--
--     local peripherals = require("types.peripherals")
--     local chest = peripheral.wrap("left") as peripherals.Inventory
--     print(chest.size())

local record peripheral
   -- A wrapped peripheral: a table of methods whose signatures are only known
   -- at runtime.
   type Peripheral = {string: function(...: any): any...}

   -- Predicate passed to `peripheral.find`, receiving the peripheral's name and
   -- the wrapped peripheral itself.
   type FindFilter = function(string, Peripheral): boolean

   getNames: function(): {string}
   isPresent: function(name: string): boolean
   getType: function(peripheral: string | Peripheral): string...
   hasType: function(peripheral: string | Peripheral, peripheral_type: string): boolean
   getMethods: function(name: string): {string}
   getName: function(peripheral: Peripheral): string
   call: function(name: string, method: string, ...: any): any...
   wrap: function(name: string): Peripheral
   find: function(ty: string, filter?: FindFilter): Peripheral...
end

return peripheral

-- CC:Tweaked's additions to the `os` table.
-- https://tweaked.cc/module/os.html
--
-- Teal's standard library already declares `global record os` and refuses to
-- let us extend it, so CC's own functions are declared separately and reached
-- with a cast at the top of each file that needs them:
--
--    local os = _G.os as ccos   -- `local os = _G.os` once compiled
--    local id = os.getComputerID()
--
-- Only CC's additions are declared here; shadowing `os` this way hides the
-- standard `os.time`/`os.clock`/`os.date`, so they are redeclared too.

local record ccos
   version: function(): string
   getComputerID: function(): integer
   computerID: function(): integer
   getComputerLabel: function(): string
   computerLabel: function(): string
   setComputerLabel: function(label?: string)

   run: function(env: {string: any}, path: string, ...: any): boolean
   queueEvent: function(name: string, ...: any)
   -- Returns the event name followed by its parameters.
   pullEvent: function(filter?: string): any...
   pullEventRaw: function(filter?: string): any...
   sleep: function(time: number)

   startTimer: function(time: number): integer
   cancelTimer: function(token: integer)
   setAlarm: function(time: number): integer
   cancelAlarm: function(token: integer)

   shutdown: function()
   reboot: function()

   -- CC's `os.time`/`os.day`/`os.epoch` take a locale ("ingame", "utc",
   -- "local") and work in in-game hours rather than the Lua stdlib's units.
   time: function(locale?: string | {string: any}): number
   day: function(locale?: string): integer
   epoch: function(locale?: string): integer
   clock: function(): number
   date: function(format?: string, time?: integer): string | {string: any}
end

return ccos

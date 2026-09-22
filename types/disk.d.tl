-- Type declarations for the CC:Tweaked `disk` API.
-- https://tweaked.cc/module/disk.html

local peripherallib = require("types.peripheral")

local record disk
   type Drive = string | peripherallib.Peripheral

   isPresent: function(drive: Drive): boolean
   getLabel: function(drive: Drive): string
   setLabel: function(drive: Drive, label?: string)
   hasData: function(drive: Drive): boolean
   getMountPath: function(drive: Drive): string
   hasAudio: function(drive: Drive): boolean
   getAudioTitle: function(drive: Drive): string | boolean
   playAudio: function(drive: Drive)
   stopAudio: function(drive?: Drive)
   eject: function(drive: Drive)
   getID: function(drive: Drive): integer
end

return disk

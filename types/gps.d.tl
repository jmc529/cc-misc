-- Type declarations for the CC:Tweaked `gps` API.
-- https://tweaked.cc/module/gps.html

local record gps
   CHANNEL_GPS: integer

   -- Returns this computer's x, y and z coordinates, or nothing if the position
   -- could not be established.
   locate: function(timeout?: number, debug?: boolean): number, number, number
end

return gps

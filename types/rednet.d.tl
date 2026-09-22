-- Type declarations for the CC:Tweaked `rednet` API.
-- https://tweaked.cc/module/rednet.html

local record rednet
   CHANNEL_BROADCAST: integer
   CHANNEL_REPEAT: integer
   MAX_ID_CHANNELS: integer

   open: function(modem: string)
   close: function(modem?: string)
   isOpen: function(modem?: string): boolean
   send: function(recipient: integer, message: any, protocol?: string): boolean
   broadcast: function(message: any, protocol?: string)
   -- Returns the sender's id, the message and the protocol it was sent on, or
   -- nothing if the call timed out.
   receive: function(protocol_filter?: string | number, timeout?: number): integer, any, string
   host: function(protocol: string, hostname: string)
   unhost: function(protocol: string)
   lookup: function(protocol: string, hostname?: string, timeout?: number): integer...
   run: function()
end

return rednet

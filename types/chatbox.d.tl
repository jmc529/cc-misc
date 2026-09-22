-- Type declarations for SwitchCraft's chatbox peripheral, which is exposed as
-- a global rather than through `peripheral.wrap`.
-- https://docs.sc3.io/faq/chatbox.html

local record chatbox
   -- Events the chatbox queues. `os.pullEvent("chat_ingame")` yields the event
   -- name, the sender, the message and one of these.
   record ChatEvent
      time: string
      rawText: string
      renderedText: string
      uuid: string
   end

   record CommandEvent
      time: string
      ownerOnly: boolean
      uuid: string
   end

   -- `mode` is "markdown" or "format"; both send functions return false plus a
   -- reason when rate limited or when the license has expired.
   tell: function(username: string, message: string, label?: string, prefix?: string, mode?: string): boolean, string
   say: function(message: string, label?: string, prefix?: string, mode?: string): boolean, string

   isConnected: function(): boolean
   getLicenseOwner: function(): string
   getCapabilities: function(): {string}
   getPlayerList: function(): {string}
end

return chatbox

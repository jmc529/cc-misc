-- Type-only declarations for the chat.sc3.io v2 websocket API, which the
-- chatbox scripts read events from.
-- https://docs.sc3.io/faq/chatbox.html
--
-- Every packet arrives as JSON, so these records describe the result of
-- `textutils.unserialiseJSON`. Fields that only appear on some event types are
-- present on the one record, hence everything but `type` being optional in
-- practice.

local record sc3
   record User
      uuid: string
      name: string
      displayName: string
      group: string
      pronouns: string
      world: string
   end

   record Packet
      -- "event", "success", "error", "hello" or "closing".
      type: string
      -- For type == "event": "chat_ingame", "chat_discord", "command",
      -- "join", "leave" or "death".
      event: string
      time: string

      user: User
      text: string
      rawText: string
      renderedText: string

      -- Only on "command" events.
      command: string
      args: {string}
      ownerOnly: boolean

      -- Only on "error" packets.
      error: string
      message: string
   end
end

return sc3

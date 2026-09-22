-- Speaks chat messages from a given player through a speaker, using
-- music.madefor.cc's text to speech service.

local dfpwm = require("cc.audio.dfpwm")
local os = _G.os as ccos

local SPEAKER_NAME: string = nil
local SPEAK_FOR = "informer"

local speaker = (SPEAKER_NAME ~= nil
   and peripheral.wrap(SPEAKER_NAME)
   or peripheral.find("speaker")) as peripherals.Speaker
if speaker == nil then
   error("No speaker attached", 0)
end

local decoder = dfpwm.make_decoder()

while true do
   local _, user, message = os.pullEvent("chat_ingame")

   if user as string == SPEAK_FOR then
      local url = "https://music.madefor.cc/tts?voice=en-us&text=" .. textutils.urlEncode(message as string)
      local response, err = http.get({ url = url, binary = true })
      if not response then error(err, 0) end

      while true do
         local chunk = response.read(16 * 1024)
         if not chunk then break end

         local buffer = decoder(chunk)
         while not speaker.playAudio(buffer) do
            os.pullEvent("speaker_audio_empty")
         end
      end
   end
end

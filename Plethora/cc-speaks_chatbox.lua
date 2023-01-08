local SPEAKER_NAME = nil

local speaker = SPEAKER_NAME ~= nil and peripheral.wrap(SPEAKER_NAME) or peripheral.find("speaker")
local decoder = require("cc.audio.dfpwm").make_decoder()

while true do
    local event, user, message, data = os.pullEvent("chat_ingame")

    if user == "informer" then
        local url = "https://music.madefor.cc/tts?voice=en-us&text=" .. textutils.urlEncode(message)
        local response, err = http.get { url = url, binary = true }
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
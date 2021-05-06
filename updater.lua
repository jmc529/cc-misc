local files = {{"updater", "yQkfXcuK"}, {"bta", "MdD051uF"}, 
    {"miner", "MAL75JX6"}, {"farmer", }, {"lumberjack", }}

--[[
This program is meant to be used to keep my turtles up to date,
but can be used with any program as long as it is on pastebin
]]--

local function updateFiles()
    for i=1,#files do
        for path, code in ipairs(files[i]) do
            update(path, code)
        end
    end
end

local function addFile(filepath, pastebincode)
    table.insert(files, {filepath, pastebincode})
end

local function update(filepath, pastebincode)
    local webHandle = http.get("http://pastebin.com/raw.php?i="..pastebincode)
    if webHandle then
        local data = webHandle.readAll()
        webHandle.close()
        local fileHandle = fs.open(filepath, "w")
        fileHandle.write(data)
        fileHandle.close()
        return
    else
        error("Could not retrieve file: "..filepath.."!")
        error("Ensure that the HTTP API is enabled.")
        return
    end
end
local expect = require("cc.expect").expect

if not fs.exists("libs/ecc.lua") then
    if not fs.exists("libs/") then fs.makeDir("libs") end
    shell.run("pastebin", "get", "ZGJGBJdg", "libs/ecc.lua")
end

local ecc = require("libs/ecc")

if not fs.exists(".keys/") then
    fs.makeDir(".keys/")
end

local sPath = ".keys/"..os.getComputerID()..".key"
local pPath = sPath..".pub"

local function loadKeys()
    local sFile = fs.exists(sPath) and fs.open(sPath, "r") or nil
    local pFile = fs.exists(pPath) and fs.open(pPath, "r") or nil
    if sFile == nil then
        sKey, pKey = ecc.keypair(ecc.random.random())
        sFile = fs.open(sPath, "w")
        pFile = fs.open(pPath, "w")
        sFile.write(string.char(unpack(sKey)))
        pFile.write(string.char(unpack(pKey)))
        sFile.close()
        pFile.close()
    else
        sKey = sFile.readAll()
        pKey = pFile.readAll()
        sFile.close()
        pFile.close()
    end
    return sKey, pKey
end

local function loadSharedSecret(sKey, pubKeyPath)
    expect(1, sKey, "table")
    expect(2, pubKeyPath, "string")
    if fs.exists(pubKeyPath) then
        local f = fs.open(pubKeyPath, "r")
        local k = f.readAll()
        f.close()
        return ecc.exchange(sKey, k)
    else
        error("Public key path not found", 0)
    end
end

return { loadKeys = loadKeys, loadSharedSecret = loadSharedSecret }
-- Loads (or generates) this computer's ECC keypair and derives shared secrets
-- with other computers' public keys.

local ecc = require("libs.ecc")
local expect = require("cc.expect").expect
local os = _G.os as ccos

local KEY_DIR = ".keys/"
local LIB_DIR = "libs/"
local ECC_PASTEBIN = "ZGJGBJdg"

if not fs.exists(LIB_DIR) then fs.makeDir(LIB_DIR) end
if not fs.exists(KEY_DIR) then fs.makeDir(KEY_DIR) end
if not fs.exists(LIB_DIR .. "ecc.lua") then
   shell.run("pastebin", "get", ECC_PASTEBIN, LIB_DIR .. "ecc.lua")
end

local secretPath = KEY_DIR .. tostring(os.getComputerID()) .. ".key"
local publicPath = secretPath .. ".pub"

local record keyHandler
   loadKeys: function(): {integer}, {integer}
   loadSharedSecret: function(secretKey: {integer}, publicKeyPath: string): {integer}
end

local function readKey(path: string): {integer}
   local handle = fs.open(path, "rb")
   local contents = handle.readAll()
   handle.close()
   return { contents:byte(1, -1) }
end

local function writeKey(path: string, key: {integer})
   local handle = fs.open(path, "wb")
   handle.write(string.char(table.unpack(key)))
   handle.close()
end

-- Keys are always returned as byte arrays, which is what `ecc` consumes;
-- previously a freshly generated keypair was returned as tables but a loaded
-- one as strings.
function keyHandler.loadKeys(): {integer}, {integer}
   if fs.exists(secretPath) and fs.exists(publicPath) then
      return readKey(secretPath), readKey(publicPath)
   end

   local secretKey, publicKey = ecc.keypair(ecc.random.random())
   writeKey(secretPath, secretKey)
   writeKey(publicPath, publicKey)
   return secretKey, publicKey
end

function keyHandler.loadSharedSecret(secretKey: {integer}, publicKeyPath: string): {integer}
   expect(1, secretKey, "table")
   expect(2, publicKeyPath, "string")
   if not fs.exists(publicKeyPath) then
      error("Public key path not found", 0)
   end
   return ecc.exchange(secretKey, readKey(publicKeyPath))
end

return keyHandler

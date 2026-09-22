-- Minimal declarations for Anavrins' `ecc` library, fetched from pastebin at
-- runtime into `libs/ecc.lua` and therefore not part of the Teal build.
-- Only the functions this repository calls are declared.
--
-- Keys, signatures and ciphertexts are all byte arrays (`{integer}`).

local record ecclib
   type Bytes = {integer}

   record Random
      random: function(): Bytes
      save: function()
   end

   random: Random

   -- Returns the secret key followed by the public key.
   keypair: function(seed?: Bytes): Bytes, Bytes
   exchange: function(secretKey: Bytes, publicKey: Bytes): Bytes
   encrypt: function(data: string | Bytes, key: Bytes): Bytes
   decrypt: function(data: Bytes, key: Bytes): Bytes
   sign: function(secretKey: Bytes, data: string | Bytes): Bytes
   verify: function(publicKey: Bytes, data: string | Bytes, signature: Bytes): boolean
end

return ecclib

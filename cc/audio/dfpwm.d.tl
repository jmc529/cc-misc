-- Declarations for CC:Tweaked's `cc.audio.dfpwm` rom module.
-- https://tweaked.cc/library/cc.audio.dfpwm.html

local record dfpwmlib
   -- Decoders and encoders are stateful: one per stream, reused for every
   -- chunk of that stream.
   type Decoder = function(input: string): {integer}
   type Encoder = function(input: {integer}): string

   make_decoder: function(): Decoder
   make_encoder: function(): Encoder

   decode: function(input: string): {integer}
   encode: function(input: {integer}): string
end

return dfpwmlib

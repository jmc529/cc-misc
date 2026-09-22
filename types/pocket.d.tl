-- Type declarations for the CC:Tweaked `pocket` API, available on pocket
-- computers.
-- https://tweaked.cc/module/pocket.html

local record pocket
   equipBack: function(): boolean, string
   unequipBack: function(): boolean, string
end

return pocket

-- Type declarations for the CC:Tweaked `multishell` API, available on advanced
-- computers.
-- https://tweaked.cc/module/multishell.html

local record multishell
   getFocus: function(): integer
   setFocus: function(n: integer): boolean
   getTitle: function(n: integer): string
   setTitle: function(n: integer, title: string)
   getCurrent: function(): integer
   launch: function(env: {string: any}, path: string, ...: string): integer
   getCount: function(): integer
end

return multishell

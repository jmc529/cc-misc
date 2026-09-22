-- Type declarations for the CC:Tweaked `help` API.
-- https://tweaked.cc/module/help.html

local record help
   path: function(): string
   setPath: function(path: string)
   lookup: function(topic: string): string
   topics: function(): {string}
   completeTopic: function(prefix: string): {string}
end

return help

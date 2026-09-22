-- Type declarations for the CC:Tweaked `parallel` API.
-- https://tweaked.cc/module/parallel.html

local record parallel
   type Task = function()

   waitForAny: function(...: Task): integer
   waitForAll: function(...: Task)
end

return parallel

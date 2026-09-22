-- Type declarations for the CC:Tweaked `settings` API.
-- https://tweaked.cc/module/settings.html

local record settings
   record Options
      description: string
      default: any
      type: string
   end

   record Details
      description: string
      default: any
      type: string
      value: any
      changed: boolean
   end

   define: function(name: string, options?: Options)
   undefine: function(name: string)
   set: function(name: string, value: any)
   get: function(name: string, default?: any): any
   getDetails: function(name: string): Details
   unset: function(name: string)
   clear: function()
   getNames: function(): {string}
   load: function(path?: string): boolean
   save: function(path?: string): boolean
end

return settings

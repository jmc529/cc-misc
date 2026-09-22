-- Type declarations for the `commands` API, available on command computers.
-- https://tweaked.cc/module/commands.html

local record commands
   -- `commands.native` is the API itself; the `commands` table also lets you
   -- run commands by indexing it, e.g. `commands.say("hi")`, which is too
   -- dynamic to type. Use `commands.exec` instead.
   native: commands
   async: {string: function(...: any): integer}

   exec: function(command: string): boolean, {string}, integer
   execAsync: function(command: string): integer
   list: function(...: string): {string}
   getDimension: function(): string
   getBlockPosition: function(): integer, integer, integer
   getBlockInfo: function(x: integer, y: integer, z: integer, dimension?: string): {string: any}
   getBlockInfos: function(minX: integer, minY: integer, minZ: integer, maxX: integer, maxY: integer, maxZ: integer, dimension?: string): {{string: any}}
   getEntities: function(selector: string): {{string: any}}
end

return commands

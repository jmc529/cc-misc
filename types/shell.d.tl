-- Type declarations for the CC:Tweaked `shell` API.
-- https://tweaked.cc/module/shell.html

local record shell
   type CompletionFn = function(shell, string, {string}): {string}

   record CompletionInfo
      fnComplete: CompletionFn
   end

   execute: function(command: string, ...: string): boolean
   run: function(...: string): boolean
   exit: function()
   dir: function(): string
   setDir: function(dir: string)
   path: function(): string
   setPath: function(path: string)
   resolve: function(path: string): string
   resolveProgram: function(command: string): string
   programs: function(include_hidden?: boolean): {string}
   complete: function(line: string): {string}
   completeProgram: function(program: string): {string}
   setCompletionFunction: function(program: string, complete: CompletionFn)
   getCompletionInfo: function(): {string: CompletionInfo}
   getRunningProgram: function(): string
   setAlias: function(command: string, program: string)
   clearAlias: function(command: string)
   aliases: function(): {string: string}

   -- Only available under the advanced (multishell) shell.
   openTab: function(...: string): integer
   switchTab: function(id: integer)
end

return shell

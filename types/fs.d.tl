-- Type declarations for the CC:Tweaked `fs` API.
-- https://tweaked.cc/module/fs.html

local record fs
   record Attributes
      size: integer
      isDir: boolean
      isReadOnly: boolean
      created: integer
      modified: integer
   end

   -- A file handle. Which methods are actually present depends on the mode the
   -- file was opened with: read modes ("r", "rb") provide `read`/`readAll`/
   -- `readLine`, write and append modes ("w", "a", "wb", "ab") provide
   -- `write`/`writeLine`/`flush`. Teal cannot discriminate between two record
   -- types at runtime, so both sets live on one record.
   record Handle
      read: function(count?: integer): string
      readAll: function(): string
      readLine: function(withTrailing?: boolean): string
      write: function(value: string | number)
      writeLine: function(text: string)
      flush: function()
      seek: function(whence?: string, offset?: integer): integer, string
      close: function()
   end

   list: function(path: string): {string}
   combine: function(path: string, ...: string): string
   getName: function(path: string): string
   getDir: function(path: string): string
   getSize: function(path: string): integer
   exists: function(path: string): boolean
   isDir: function(path: string): boolean
   isReadOnly: function(path: string): boolean
   makeDir: function(path: string)
   move: function(path: string, dest: string)
   copy: function(path: string, dest: string)
   delete: function(path: string)
   getDrive: function(path: string): string
   getFreeSpace: function(path: string): integer | string
   getCapacity: function(path: string): integer
   attributes: function(path: string): Attributes

   -- `open` returns `nil` plus an error message when the file cannot be opened,
   -- so the handle must be checked before use.
   open: function(path: string, mode: string): Handle, string

   find: function(path: string): {string}
   isDriveRoot: function(path: string): boolean
   complete: function(path: string, location: string, include_dirs?: boolean, include_files?: boolean): {string}
end

return fs

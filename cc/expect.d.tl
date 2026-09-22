-- Declarations for CC:Tweaked's `cc.expect` rom module.
-- https://tweaked.cc/library/cc.expect.html

local record expectlib
   -- Errors if `value` is not one of the given types; returns `value`.
   expect: function(index: integer, value: any, ...: string): any
   field: function(tbl: {string: any}, index: string, ...: string): any
   range: function(num: number, min?: number, max?: number): number
end

return expectlib

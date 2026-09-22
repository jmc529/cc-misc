-- Type declarations for the CC:Tweaked `textutils` API.
-- https://tweaked.cc/module/textutils.html

local record textutils
   record SerializeOptions
      compact: boolean
      allow_repetitions: boolean
   end

   record JSONOptions
      nbt_style: boolean
      unicode_strings: boolean
      allow_repetitions: boolean
      parse_null: boolean
      parse_empty_array: boolean
   end

   -- Sentinel values used when (de)serialising JSON.
   empty_json_array: any
   json_null: any

   slowWrite: function(text: any, rate?: number)
   slowPrint: function(text: any, rate?: number)
   formatTime: function(time: number, twentyFourHour?: boolean): string
   pagedPrint: function(text: any, free_lines?: integer): integer

   -- Both accept strings and colour numbers, hence `any`.
   tabulate: function(...: any)
   pagedTabulate: function(...: any)

   serialize: function(value: any, opts?: SerializeOptions): string
   serialise: function(value: any, opts?: SerializeOptions): string
   unserialize: function(s: string): any
   unserialise: function(s: string): any

   serializeJSON: function(value: any, options?: JSONOptions | boolean): string
   serialiseJSON: function(value: any, options?: JSONOptions | boolean): string
   unserializeJSON: function(s: string, options?: JSONOptions): any
   unserialiseJSON: function(s: string, options?: JSONOptions): any

   urlEncode: function(str: string): string
   complete: function(searchText: string, searchTable?: table): {string}
end

return textutils

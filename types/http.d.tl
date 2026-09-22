-- Type declarations for the CC:Tweaked `http` API.
-- https://tweaked.cc/module/http.html

local record http
   record Request
      url: string
      body: string
      headers: {string: string}
      binary: boolean
      method: string
      redirect: boolean
      timeout: number
   end

   record WebsocketRequest
      url: string
      headers: {string: string}
      timeout: number
   end

   -- The handle returned by `http.get`/`http.post`/`http.request`. It is a
   -- read handle with a few HTTP specific methods bolted on.
   record Response
      read: function(count?: integer): string
      readAll: function(): string
      readLine: function(withTrailing?: boolean): string
      seek: function(whence?: string, offset?: integer): integer, string
      close: function()
      getResponseCode: function(): integer, string
      getResponseHeaders: function(): {string: string}
   end

   record Websocket
      -- Returns the message and whether it was binary, or nothing on timeout.
      receive: function(timeout?: number): string, boolean
      send: function(message: string, binary?: boolean)
      close: function()
   end

   -- All request functions return `nil` plus an error message on failure, and
   -- may return a failed `Response` as the third result.
   get: function(url: string | Request, headers?: {string: string}, binary?: boolean): Response, string, Response
   post: function(url: string | Request, body?: string, headers?: {string: string}, binary?: boolean): Response, string, Response
   request: function(url: string | Request, body?: string, headers?: {string: string}, binary?: boolean)
   checkURL: function(url: string): boolean, string
   checkURLAsync: function(url: string): boolean, string
   websocket: function(url: string | WebsocketRequest, headers?: {string: string}): Websocket, string
   websocketAsync: function(url: string | WebsocketRequest, headers?: {string: string}): boolean, string
end

return http

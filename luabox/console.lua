local csi = require('luabox.util').csi

local success, uv = pcall(require, 'luv')

if not success then
   success, uv = pcall(require, 'uv')
end

assert(success, uv)

--- The Console, storing the stdin and stdout as well as some functions to control them
---@class Console
---@field public rawMode number The number to set the console to raw mode
---@field public normalMode number The number to set the console to normal mode
---@field public onData function | nil The hook that is called when data from stdin is received
local Console = {}
Console.__index = Console

-- Static

Console.rawMode = 1
Console.normalMode = 0

--- Check if the handle is a TTY
---@param tty tty
---@return boolean
function Console.isTTY(tty)
   return uv.guess_handle(uv.fileno(tty)) == 'tty'
end

--- Create a new Console
---
--- Make sure to call `Console.run` to `uv.run` in order for the console to operate
---
--- If you need stdin and stdout, call `util.getHandles()`
---
--- ```lua
--- Console.new(util.getHandles())
--- ```
---@param stdin tty
---@param stdout tty
---@return Console
function Console.new(stdin, stdout)
   local self = setmetatable({}, Console)

   self.stdin = stdin
   self.stdout = stdout

   self.mode = 0
   self.onData = nil
   self._locked = nil

   assert(Console.isTTY(self.stdin), 'Expected TTY!')
   assert(Console.isTTY(self.stdout), 'Expected TTY!')

   self.stdin:read_start(function(err, data)
      assert(not err, err)

      self:_on(data)
   end)

   return self
end

--- Set the mode of the console
---@param mode number
function Console:setMode(mode)
   self.mode = mode

   self.stdin:set_mode(mode)
end

--- Write data to the console
---@param data string
function Console:write(data)
   repeat
      local n, e = uv.try_write(self.stdout, data)
      if n then
         data = data:sub(n+1)
         n = 0
      else
         if e:match('^EAGAIN') then
            n = 0
         else
            assert(n, e)
         end
      end
   until n == #data

   self.stdout:write(data)
end

--- Set the console into mouse mode
function Console:intoMouseMode()
   self:write(csi('?1000h\27[?1002h\27[?1015h\27[?1006h'))
end

--- Exit mouse mode
function Console:exitMouseMode()
   self:write(csi('?1006l\27[?1015l\27[?1002l\27[?1000l'))
end

--- Get the cursor position
---
--- This function is asynchronous and must be called from a coroutine
---@param noClose boolean Force the pipe to stay open
---@return number
---@return number
function Console:cursorPosition(noClose)
   local previousMode = self.mode

   self:setMode(1)

   -- Request cursor location
   self:write('\27[6n')

   local coro = coroutine.running()

   local othersReading = self.stdin:is_active()

   self:_lock(function(packet)
      if packet:match('\27%[(%d+);(%d+)R') then
         self:setMode(previousMode)

         if not othersReading and not noClose then
            -- If no other listener existed, close the stream
            self:close()
         end

         local x, y = packet:match('\27%[(%d+);(%d+)R')

         coroutine.resume(coro, tonumber(x), tonumber(y))

         return true
      end
   end)

   return coroutine.yield()
end

--- Get the dimensions of the console
---@return number
---@return number
function Console:getDimensions()
   return self.stdout:get_winsize()
end

--- Closes the console
function Console:close()
   self.stdout:shutdown()
   self.stdin:shutdown()
end

--- Alias for `uv.run`
function Console.run()
   uv.run()
end

-- Private

--- Internal function to lock the console
function Console:_lock(fn)
   self._locked = fn
end

--- Internal function that is called when data is received
function Console:_on(data)
   if self._locked then
      local res = self._locked(data)

      if res then
         self._locked = nil
      end
   else
      if data:match('\27%[(%d+);(%d+)R') then -- Ignore cursor locations
         return
      end

      if self.onData then
         self.onData(data)
      end
   end
end

return Console

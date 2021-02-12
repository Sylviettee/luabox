--- module The utilities module containing some utilities for internal use and others for external use
---@class util
local util = {}

local success, uv = pcall(require, 'luv')

if not success then
   success, uv = pcall(require, 'uv')
end

assert(success, uv)

local id = '\27['

function util.csi(key)
   return id .. key
end

--- An iterator over strings used by event parser
---@param str string The string to iterate over
---@return StringIterator
function util.StringIterator(str)
   return {
      next = function(self)
         self.pos = self.pos + 1

         local char = self.original:sub(self.pos, self.pos)

         self.str = self.str:sub(self.pos, #self.str)

         return char ~= '' and char or nil
      end,
      pos = 0,
      str = str,
      original = str
   }
end

--- A simple split function
---@param str string The string to split
---@param sep string The string to split by
---@return string[]
function util.split(str, sep)
   local ret = {}

   for part in str:gmatch('([^' .. (sep or '%s') .. ']+)') do
      table.insert(ret, part)
   end

   return ret
end

--- A function to retrieve stdin and stdout if you don't already have them
---@return tty
---@return tty
function util.getHandles()
   local stdin, stdout

   if uv.guess_handle(0) == 'tty' then
      stdin = assert(uv.new_tty(0, true))
   else
      stdin = uv.new_pipe(false)
      uv.pipe_open(stdin, 0)
   end

   if uv.guess_handle(1) == 'tty' then
      stdout = assert(uv.new_tty(1, false))
   else
      stdout = uv.new_pipe(false)
      uv.pipe_open(stdout, 1)
   end

   return stdin, stdout
end

do
--- A string iterator
---@class StringIterator
---@field public next fun(self: StringIterator): string
local _StringIterator = {}
end

return util
--- module Support for mouse and keyboard events.
---@class event
local eventMod = {}

local util = require('luabox/util')
local success, bit = pcall(require, 'bit')

if not success then
   -- Add the one bit function we need if we are using Lua5.3+
   if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) >= 5.3 then
      bit = load([[
         return {
            band = function(a, b)
               return a & b
            end
         }
      ]], 'bit', 't')()
   end
end

--; TODO; lets not let UTF8 make things not fun...

local function parseCSI(item)
   local nextChar = item:next()

   if nextChar == '[' then
      local byte = string.byte(item:next())

      if byte >= 65 and byte <= 69 then
         return {
            key = 'f',
            char = 1 + byte - 65
         }
      else
         return error('Sequence not recognized')
      end
   elseif nextChar == 'D' then
      return {
         key = 'left'
      }
   elseif nextChar == 'C' then
      return {
         key = 'right'
      }
   elseif nextChar == 'A' then
      return {
         key = 'up'
      }
   elseif nextChar == 'B' then
      return {
         key = 'down'
      }
   elseif nextChar == 'H' then
      return {
         key = 'home'
      }
   elseif nextChar == 'F' then
      return {
         key = 'end'
      }
   elseif nextChar == 'Z' then
      return {
         key = 'backTab'
      }
   elseif nextChar == 'M' then
      -- Mouse (X10)
      -- ESC [ CB Cx Cy

      if not bit then
         return error('For X10 mouse support, Lua 5.3+ must be used or `luabitop` be installed')
      end

      local cb = string.byte(item:next()) - 32
      local x = string.byte(item:next()) - 32
      x = x < 0 and x or x
      local y = string.byte(item:next()) - 32
      y = y < 0 and y or y

      local event, button = 'press', nil

      local xand = bit.band(cb, 3)

      if xand == 0 then
         if bit.band(xand, 0x40) ~= 0 then
            button = 'wheelUp'
         else
            button = 'left'
         end
      elseif xand == 1 then
         if bit.band(xand, 0x40) ~= 0 then
            button = 'wheelDown'
         else
            button = 'middle'
         end
      elseif xand == 2 then
         button = 'right'
      elseif xand == 3 then
         event = 'release'
      else
         return error('Sequence not recognized')
      end

      return {
         button = button,
         event = event,
         x = x,
         y = y
      }
   elseif nextChar == '<' then
      -- Mouse (xterm)
      -- ESC [ < Cb ; Cx ; Cy (;) (M or m)
      local buffer = {}
      local c = item:next()

      while c ~= 'm' and c ~= 'M' do
         table.insert(buffer, c)
         c = item:next()
      end

      local strBuffer = table.concat(buffer)
      local nums = util.split(strBuffer, ';')

      local cb = tonumber(nums[1])
      local x = tonumber(nums[2])
      local y = tonumber(nums[3])

      local event, button

      if cb >= 0 and cb <= 2 or cb >= 64 and cb <= 65 then
         if cb == 0 then
            button = 'left'
         elseif cb == 1 then
            button = 'middle'
         elseif cb == 2 then
            button = 'right'
         elseif cb == 64 then
            button = 'wheelUp'
         elseif cb == 65 then
            button = 'wheelDown'
         end

         event = c == 'M' and 'press' or 'release'
      elseif cb == 32 then
         event = 'hold'
      elseif cb == 3 then
         event = 'release'
      else
         return error('Sequence not recognized')
      end

      return {
         button = button,
         event = event,
         x = x,
         y = y
      }
   elseif string.byte(nextChar) >= 48 and string.byte(nextChar) <= 57 then
      -- Number escaped code
      local buffer = { tonumber(nextChar) }
      local c -- = nextChar

      while true do
         local nextItem = item:next()

         if not tonumber(nextItem) then
            c = nextItem
            break
         else
            table.insert(buffer, tonumber(nextItem))
         end
      end

      if c == 'M' then -- M
         -- Mouse (rxvt)
         -- ESC [ Cb ; Cx ; Cy ; M
         local strBuffer = table.concat(buffer)

         local nums = util.split(strBuffer, ';')

         local cb = tonumber(nums[1])
         local x = tonumber(nums[2])
         local y = tonumber(nums[3])

         local event, button = 'press', nil

         if cb == 32 then
            button = 'left'
         elseif cb == 33 then
            button = 'middle'
         elseif cb == 34 then
            button = 'right'
         elseif cb == 35 then
            event = 'release'
         elseif cb == 64 then
            event = 'hold'
         elseif cb == 96 or cb == 97 then
            event = 'wheelUp'
         else
            return error('Sequence not recognized')
         end

         return {
            button = button,
            event = event,
            x = x,
            y = y
         }
      elseif c == '~' then -- ~
         -- Special key codes
         local strBuffer = table.concat(buffer)

         local nums = {}
         local split = util.split(strBuffer, ';')

         for i = 1, #split do
            table.insert(nums, tonumber(split[i]))
         end

         local num = nums[1]

         if num == 1 or num == 7 then
            return {
               key = 'home'
            }
         elseif num == 2 then
            return {
               key = 'insert'
            }
         elseif num == 3 then
            return {
               key = 'delete'
            }
         elseif num == 4 or num == 8 then
            return {
               key = 'end'
            }
         elseif num == 5 then
            return {
               key = 'pageUp'
            }
         elseif num == 6 then
            return {
               key = 'pageDown'
            }
         elseif num >= 11 and num <= 15 then
            return {
               key = 'f',
               char = tostring(num - 10)
            }
         elseif num >= 17 and num <= 21 then
            return {
               key = 'f',
               char = tostring(num - 11)
            }
         elseif num >= 23 and num <= 24 then
            return {
               key = 'f',
               char = tostring(num - 12)
            }
         else
            return error('Sequence not recognized')
         end
      else
         return error('Sequence not recognized')
      end
   else
      return error('Sequence not recognized')
   end
end

--- Parse an event from a single character or if needed from a StringIterator
---@param item string
---@param rest StringIterator
---@return mouseEvent | keyboardEvent
function eventMod.parse(item, rest)
   if item == '\27' then
      local nextChar = rest:next()

      if nextChar == 'O' then
         nextChar = rest:next()

         -- F1-F4

         local byte = string.byte(nextChar)

         if byte >= 80 and byte <= 83 then
            return {
               key = 'f',
               char = tostring(1 + byte - 80)
            }
         else
            return error('Failed to parse event')
         end
      elseif nextChar == '[' then
         -- CSI event
         return parseCSI(rest)
      elseif nextChar then
         return {
            key = 'alt',
            char = nextChar
         }
      else -- the escape key is a just `ESC` so if the output has nothing left the key pressed must be an escape
         return {
            key = 'esc'
         }
      end
   elseif item == '\n' or item == '\r' then
      return {
         key = 'char',
         char = '\n'
      }
   elseif item == '\t' then
      return {
         key = 'char',
         char = '\t'
      }
   elseif item == string.char(127) then
      return {
         key = 'backspace'
      }
   elseif string.byte(item) >= 1 and string.byte(item) <= 26 then
      -- Control
      return {
         key = 'ctrl',
         char = string.char(string.byte(item) - 0x1 + 97)
      }
   elseif string.byte(item) >= 28 and string.byte(item) <= 31 then
      -- Control
      return {
         key = 'ctrl',
         char = string.char(string.byte(item) - 0x1C + 52)
      }
   elseif item == '\0' then
      return {
         key = 'null'
      }
   else
      return {
         key = 'char',
         char = item
      }
   end
end

do
--- struct
---@class keyboardEvent
---@field public key string The key group that was pressed (F, ctrl, key, etc)
---@field public char string | nil The character associated with the key (the 1 in F1)
local _keyboardEvent = {}

--- struct
---@class mouseEvent
---@field public event string The event that happened (clicked, held, etc)
---@field public x number | nil The X location of the mouse
---@field public y number | nil The Y location of the mouse
---@field public button string | nil The button that was pressed
local _mouseEvent = {}
end

return eventMod
--- module Cursor manipulation functions
---@class cursor
---@field public hide string Hide the cursor
---@field public show string Show the cursor
---@field public restore string Restore the cursor
---@field public save string Save the cursor
---@field public blinkingBlock string Set the style to a blinking block
---@field public steadyBlock string Set the style to a steady block
---@field public blinkingUnderline string Set the style to a blinking underline
---@field public steadyUnderline string Set the style to a steady underline
---@field public blinkingBar string Set the style to a blinking bar
---@field public steadyBar string Set the style to a steady bar
---@field public up fun(count: number): string Go up a certain count
---@field public down fun(count: number): string Go down a certain count
---@field public left fun(count: number): string Go left a certain count
---@field public right fun(count: number): string Go right a certain count
---@field public goTo fun(x: number, y: number): string Go to a specific location

local util = require('luabox.util')
local csi = util.csi

local f = string.format

local function direction(dir)
   return function(count)
      csi(f('%u%s', count or 1, dir))
   end
end

local function goTo(x, y)
   return csi(f('%u;%uH', y, x))
end

return {
   -- Hiding/showing
   hide = csi('?25l'),
   show = csi('?25h'),

   -- Saving/restoring
   restore = csi('u'),
   save = csi('s'),

   -- Cursor styles
   blinkingBlock = csi('\x31 q'),
   steadyBlock = csi('\x32 q'),
   blinkingUnderline = csi('\x33 q'),
   steadyUnderline = csi('\x34 q'),
   blinkingBar = csi('\x35 q'),
   steadyBar = csi('\x36 q'),

   -- Direction
   up = direction('A'),
   down = direction('B'),
   right = direction('C'),
   left = direction('D'),
   goTo = goTo
}

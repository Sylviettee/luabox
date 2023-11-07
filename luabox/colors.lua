local csi = require('luabox.util').csi

local f = string.format

local function background(code)
   local sec = type(code) == 'table' and code.sec or 5
   local color = type(code) == 'table' and code.color or code

   return csi(f('48;%u;%sm', sec, color))
end

local function foreground(code)
   local sec = type(code) == 'table' and code.sec or 5
   local color = type(code) == 'table' and code.color or code

   return csi(f('38;%u;%sm', sec, color))
end

local function truecolor(r, g, b)
   return {
      sec = 2,
      color = f('%u;%u;%u', r, g, b)
   }
end

--- module Coloring utilities
---
--- With colors, you pass them to either `colors.bg` or `colors.fg` in order to get the actual escape string
---
--- ```lua
--- console:write(string.format('%sLook at my red text!', colors.fg(colors.red)))
--- ```
---
---@class colors
---@field public black number
---@field public red number
---@field public green number
---@field public yellow number
---@field public blue number
---@field public magenta number
---@field public cyan number
---@field public white number
---@field public lightBlack number
---@field public lightRed number
---@field public lightGreen number
---@field public lightYellow number
---@field public lightBlue number
---@field public lightMagenta number
---@field public lightCyan number
---@field public lightWhite number
---@field public resetFg string
---@field public resetBg string
---@field public bg fun(color: number): string Get a string to change the background to the passed color
---@field public fg fun(color: number): string Get a string to change the foreground to the passed color
---@field public truecolor fun(r: number, g: number, b: number): table Pass to `bg` or `fg` in order to get a string
local colors = {
   black = 0,
   red = 1,
   green = 2,
   yellow = 3,
   blue = 4,
   magenta = 5,
   cyan = 6,
   white = 7,
   lightBlack = 8,
   lightRed = 9,
   lightGreen = 10,
   lightYellow = 11,
   lightBlue = 12,
   LightMagenta = 13,
   lightCyan = 14,
   lightWhite = 15,
   resetFg = csi('39m'),
   resetBg = csi('49m'),
   bg = background,
   fg = foreground,
   truecolor = truecolor,
}

return colors

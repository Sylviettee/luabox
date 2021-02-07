local csi = require('luabox/util').csi

--- module Strings to clear the screen
---@class clear
---@field public all string Clear the entire screen
---@field public afterCursor string Clear the data after the cursor
---@field public beforeCursor string Clear the data before the cursor
---@field public currentLine string Clear the current line
---@field public untilNewLine string Clear the screen until a new line
local clear = {
   all = csi('2J'),
   afterCursor = csi('J'),
   beforeCursor = csi('1J'),
   currentLine = csi('2K'),
   untilNewLine = csi('K')
}

return clear
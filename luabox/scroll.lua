local csi = require('luabox/util').csi

local function direction(dir)
   return function(x)
      return csi(x .. dir)
   end
end

--- module Simple scroll functionality
---@class scroll
---@field public up fun(count: number): string Scroll up
---@field public down fun(count: number): string Scroll down
local scroll = {
   up = direction('S'),
   down = direction('T')
}

return scroll
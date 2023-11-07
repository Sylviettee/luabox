local csi = require('luabox.util').csi

--- module Allows for switching between the main and alternative screen buffers
---
--- This buffer only exists on xterm compatible terminals
---@class screen
---@field public toAlternative string Switch to the alternative screen
---@field public toMain string Switch to the main screen
local screen = {
   toAlternative = csi('?1049h'),
   toMain = csi('?1049l')
}

return screen

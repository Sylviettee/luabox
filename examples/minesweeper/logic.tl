local box = require('luabox')
local colors = box.colors

local f = string.format

local record Cell
   mine: boolean
   revealed: boolean
   flagged: boolean
   x: number
   y: number
end

local record Game
   width: number
   grid: {{Cell}}
   term: luabox.Console
   gameOver: boolean
end

-- Constants
local cellBg = '▒'

local bounds = {
   horizontal = '─',
   vertical = '│',
   topLeftCorner = '┌',
   topRightCorner = '┐',
   bottomLeftCorner = '└',
   bottomRightCorner = '┘'
}

local function bombsNear(current: Cell, grid: {{Cell}}): number | nil
   --[[
   [1][1][2][1][1]
   [1][*][2][*][1]
   [1][1][2][1][1]

   Scans in a 9 cell area around the current cell
   ]]

   if current.mine then
      return
   end

   local near = 0
   local hasRevealed = false

   local xLong = #grid[current.y]

   for x = (current.x - 1 < 1 and 1 or current.x - 1), 
      (current.x + 1 > xLong and xLong or current.x + 1 )
   do
      for y = (current.y - 1 < 1 and 1 or current.y - 1),
         (current.y + 1 > #grid and #grid or current.y + 1 )
      do
         if not (x == current.x and y == current.y) and grid[y][x] then
            local cell = grid[y][x]

            if cell.revealed then
               hasRevealed = true
            end

            if cell.mine then
               near = near + 1
            end
         end
      end
   end

   return near
end

function Game.new(term: luabox.Console): Game
   local self = setmetatable({} as Game, {
      __index = Game
   })

   self.width = term:getDimensions()
   self.term = term
   self.grid = {{}}

   return self
end

function Game:setup(difficulty: number, cells: number)
   local cellsPerRow = math.sqrt(cells)
   local row = 1
   local col = 1

   self.grid = {{}}
   self.gameOver = false

   for i = 1, cells do
      col = col + 1

      if i % cellsPerRow - 1 == 0 then
         row = row + 1
         col = 1
         table.insert(self.grid, {})
      end

      local cell = {
         mine = math.random(0, difficulty) > 5,
         revealed = false,
         flagged = false,
         x = col,
         y = row - 1
      }

      table.insert(self.grid[row], cell)
   end

   table.remove(self.grid, 1)
end

function Game:render(): string
   local rows: {string} = {}

   for y = 1, #self.grid do
      table.insert(rows, '')
      for x = 1, #self.grid[y] do
         local cell = self.grid[y][x]
         local near = bombsNear(cell, self.grid)

         local renderedCell = (
            cell.revealed and (
               cell.mine and cellBg or
               near == 0 and ' ' or
               tostring(near)
            ) or
            cellBg
         )

         rows[y] = rows[y] .. colors.fg(
            cell.flagged and colors.white or
            (cell.mine and cell.revealed) and colors.red or
            cell.revealed and colors.white or
            colors.black
         ) .. renderedCell .. colors.resetFg
      end
   end

   local border = bounds.topLeftCorner .. (string.rep(bounds.horizontal, #self.grid[1])) .. bounds.topRightCorner

   for i = 1, #rows do
      border = border .. '\n' .. bounds.vertical .. rows[i] .. bounds.vertical
   end

   border = border .. '\n' .. bounds.bottomLeftCorner .. (string.rep(bounds.horizontal, #self.grid[1])) .. bounds.bottomRightCorner

   return border:match('^%s*(.-)%s*$')
end

function Game:goTo(x: number, y: number)
   if self.gameOver then
      return
   end

   -- local actualX, actualY = 
   --    (x * 3) * 2 - 3,
   --    ((y + 1) * 3) - 4

   self.term:write(box.cursor.goTo(x + 1, y + 1))
end

function Game:flag(x: number, y: number)
   if self.gameOver then
      return
   end

   self.grid[y][x].flagged = not self.grid[y][x].flagged
end

function Game:reveal(x: number, y: number)
   if self.gameOver then
      return
   end

   self.grid[y][x].revealed = true

   if self.grid[y][x].mine then
      self.gameOver = true
   end
end

return Game
local Game = require('examples.minesweeper.logic')
local box = require('luabox')

local util = box.util
local event = box.event
local clear = box.clear
local cursor = box.cursor

local f = string.format

local stdin, stdout = util.getHandles()

local console = box.Console.new(stdin, stdout)

local game = Game.new(console)

local difficulty, cells = 6, 100

console:write(f('%s%s', cursor.goTo(1, 1), clear.all))

game:setup(difficulty, cells)

console:setMode(1)
console:intoMouseMode()

console:write(game:render())

local x, y = 1, 1

game:goTo(x, y)

console.onData = function(data: string)
   local first: string
   local rest: {string} = {}

   for char in data:gmatch('.') do
      if not first then
         first = char
      else
         table.insert(rest, char)
      end
   end

   local iter = util.StringIterator(table.concat(rest))

   local keyData = event.parse(first, iter)

   if keyData.key == 'ctrl' and keyData.char == 'c' then
      console:write(cursor.show)
      console:setMode(0)
      console:exitMouseMode()
      console:close()

      os.exit()
   elseif keyData.key == 'ctrl' and keyData.char == 'r' then
      console:write(clear.all)
      game:setup(difficulty, cells)
   elseif keyData.key == 'left' then
      x = x - 1
   elseif keyData.key == 'right' then
      x = x + 1
   elseif keyData.key == 'up' then
      y = y - 1
   elseif keyData.key == 'down' then
      y = y + 1
   elseif keyData.event and keyData.event == 'release' and keyData.x then
      x = keyData.x
      y = keyData.y
   elseif keyData.key == 'char' and keyData.char == 'f' then
      game:flag(x, y)
   elseif keyData.key == 'char' and keyData.char == 'r' then
      game:reveal(x, y)
   end

   console:write(
      cursor.goTo(1, 1) ..
      clear.all ..
      game:render()
   )

   game:goTo(x, y)

   if game.gameOver then
      console:write(
         cursor.goTo(1, #game.grid + 3) ..'Game over!'
      )
   end
end

console.run()

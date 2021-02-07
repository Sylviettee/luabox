# Luabox

Luabox is a rewrite of [Termion](https://github.com/redox-os/termion) for Lua using [Luv](https://github.com/luvit/luv).

## Features

* Raw mode
* TrueColor
* ~~Panic-full error handling~~
* Special key event support (modifiers, special keys)
* Async I/O
* Mouse support
* And more!

## Installation

```sh
[sudo] luarocks install luabox
[sudo] luarocks install luabitop # For Lua versions >5.3
```

## Quick example

This quick example shows how you can use mouse support to plot points on your terminal.

```lua
local box = require('luabox')

local util = box.util
local event = box.event
local clear = box.clear
local cursor = box.cursor

local f = string.format

local stdin, stdout = util.getHandles()

local console = box.Console.new(stdin, stdout)

console:setMode(1)
console:intoMouseMode()

console:write(f('%s%s', cursor.hide, clear.all))

console.onData = function(data)
   local first
   local rest = {}

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

      os.exit()
   elseif keyData.key == 'char' and keyData.char == 'c' then
      console:write(clear.all)
   elseif keyData.event and keyData.event ~= 'press' then
      local x, y = keyData.x, keyData.y

      console:write(f('%sX', cursor.goTo(x, y)))
   end
end

console.run()
```

For a larger example run `./make.sh minesweeper`. This example is a (terrible) clone of minesweeper.

You will need [teal](https://github.com/teal-language/tl) in-order to compile.
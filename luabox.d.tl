global record luabox
   -- Non-modules
   record tty
   end

   record StringIterator
      next: function(self: StringIterator)
      pos: integer
      str: string
      original: string
   end

   record eventStruct
      key: keys | nil
      char: string | nil
      button: buttons | nil
      event: events | nil
      x: integer | nil
      y: integer | nil
   end

   enum keys
      'backspace'
      'left'
      'right'
      'up'
      'down'
      'home'
      'end'
      'pageUp'
      'pageDown'
      'backTab'
      'delete'
      'insert'
      'null'
      'esc'
      'f'
      'char'
      'alt'
      'ctrl'
   end

   enum buttons
      'left'
      'right'
      'middle'
      'wheelUp'
      'wheelDown'
   end

   enum events
      'press'
      'release'
      'hold'
   end

   -- Modules

   record clear
      all: string
      afterCursor: string
      beforeCursor: string
      currentLine: string
      untilNewline: string
   end

   record colors
      black: integer
      red: integer
      green: integer
      yellow: integer
      blue: integer
      magenta: integer
      cyan: integer
      white: integer

      lightBlack: integer
      lightRed: integer
      lightGreen: integer
      lightYellow: integer
      lightBlue: integer
      lightMagenta: integer
      lightCyan: integer
      lightWhite: integer

      resetFg: string
      resetBg: string

      bg: function(code: integer | truecolorOut): string
      fg: function(code: integer | truecolorOut): string
      truecolor: function(r: integer, g: integer, b: integer): truecolorOut

      record truecolorOut
         sec: integer
         color: string
      end
   end

   record cursor
      hide: string
      show: string

      restore: string
      save: string

      blinkingBlock: string
      steadyBlock: string
      blinkingUnderline: string
      steadyUnderline: string
      blickingBar: string
      steadyBar: string

      up: function(count: integer | nil): string
      down: function(count: integer | nil): string
      right: function(count: integer | nil): string
      left: function(count: integer | nil): string
      goTo: function(x: integer, y: integer): string
   end

   record event
      parse: function(first: string, rest: StringIterator): eventStruct
   end

   record scroll
      up: function(count: integer | nil): string
      down: function(count: integer | nil): string
   end

   record util
      csi: function(key: string): string
      split: function(str: string, sep: string): {string}
      getHandles: function(): tty, tty
      StringIterator: function(str: string): StringIterator
   end

   -- Classes

   record Console
      new: function(stdin: tty, stdout: tty): Console

      rawMode: integer
      normalMode: integer
      isTTY: function(tty: tty): boolean

      onData: function(data: string)

      run: function()
      intoMouseMode: function(self: Console)
      exitMouseMode: function(self: Console)
      write: function(self: Console, data: string)
      setMode: function(self: Console, mode: integer)
      cursorPosition: function(self: Console, noClose: boolean | nil): integer, integer
      getDimensions: function(self: Console): integer, integer
      close: function(self: Console)
   end
end

return luabox

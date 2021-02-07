global record luabox
   -- Non-modules
   record tty
   end

   record StringIterator
      next: function(self: StringIterator)
      pos: number
      str: string
      original: string
   end

   record eventStruct
      key: keys | nil
      char: string | nil
      button: buttons | nil
      event: events | nil
      x: number | nil
      y: number | nil
   end

   enum keys
      'backspace'
      'left'
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
      black: number
      red: number
      green: number
      yellow: number
      blue: number
      magenta: number
      cyan: number
      white: number

      lightBlack: number
      lightRed: number
      lightGreen: number
      lightYellow: number
      lightBlue: number
      lightMagenta: number
      lightCyan: number
      lightWhite: number

      resetFg: string
      resetBg: string

      bg: function(code: number | truecolorOut): string
      fg: function(code: number | truecolorOut): string
      truecolor: function(r: number, g: number, b: number): truecolorOut

      record truecolorOut
         sec: number
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

      up: function(count: number | nil): string
      down: function(count: number | nil): string
      right: function(count: number | nil): string
      left: function(count: number | nil): string
      goTo: function(x: number, y: number): string
   end

   record event
      parse: function(first: string, rest: StringIterator): eventStruct
   end

   record scroll
      up: function(count: number | nil): string
      down: function(count: number | nil): string
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

      rawMode: number
      normalMode: number
      isTTY: function(tty: tty): boolean

      onData: function(data: string)

      run: function()
      intoMouseMode: function(self: Console)
      exitMouseMode: function(self: Console)
      write: function(self: Console, data: string)
      setMode: function(self: Console, mode: number)
      cursorPosition: function(self: Console, noClose: boolean | nil): number, number
      getDimensions: function(self: Console): number, number
   end
end

return luabox
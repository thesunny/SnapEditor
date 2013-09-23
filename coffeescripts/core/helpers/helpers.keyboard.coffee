# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["core/browser"], (Browser) ->
  return {
    # Keyboard key mappings taken from MooTools.
    keys:
      enter: 13
      up: 38
      down: 40
      left: 37
      right: 39
      esc: 27
      space: 32
      backspace: 8
      tab: 9
      delete: 46
      home: 36
      end: 35
      pageup: 33
      pagedown: 34
      "-": if Browser.isGecko then 173 else 189
      "=": if Browser.isGecko then 61 else 187

    # Returns the string representation of the key pressed. Taken from MooTools.
    keyOf: (event) ->
      # Check for function key.
      if event.type == 'keydown'
        fKey = event.which - 111
        key = 'f' + fKey if 0 < fKey < 13
      unless key
        # Check for special key.
        for own k, v of @keys
          key = k if v == event.which
        # If still no match, a character key was pressed.
        key = String.fromCharCode(event.which).toLowerCase() unless key
      key

    # Returns the string representation of the keys pressed. Includes alt,
    # ctrl, and shift.
    keysOf: (event) ->
      key = @keyOf(event)
      specialKeys = []
      specialKeys.push('alt') if event.altKey
      specialKeys.push('ctrl') if event.ctrlKey
      specialKeys.push('shift') if event.shiftKey
      @buildKey(key, specialKeys)

    # Given a string of special keys and key, returns the normalized string
    # key.
    normalizeKeys: (key) ->
      keys = key.split('+')
      char = keys.pop()
      @buildKey(char, keys)

    # Sorts the special keys and joins the special keys and key using the
    # delimiter.
    buildKey: (key, specialKeys=[], delim='+') ->
      keys = specialKeys.sort()
      keys.push(key)
      keys.join(delim)
  }

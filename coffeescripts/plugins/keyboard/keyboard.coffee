# Keyboard API:
# * getKeyboardShortcuts():
#     Returns an object with keys corresponding to the keyboard shortcut. The
#     values event handler functions to be called when the shortcut is pressed.
#     Note the special keys:
#       * alt
#       * ctrl
#       * shift
#       * enter
#       * up, down, left, right
#       * esc
#       * space
#       * backspace
#       * tab
#       * delete
#
# This handles listening to the keyboard and calling the event handlers.
#
# The type argument is the keyboard event the event handlers will be attached
# to.
#
# The keys argument is an object with the keyboard shortcut as the key and the
# event handler as the value.
#
# The el argument determines which element to listen to. It defaults to the
# body.
define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  class Keyboard
    constructor: (@plugins, @type, el = document.body) ->
      @$el = $(el)
      @keys = {}
      @setupPlugins()

    register: (@api) ->
      @api.on("activate.editor", @start)
      @api.off("deactivate.editor", @stop)

    setupPlugins: ->
      @add(plugin.getKeyboardShortcuts()) for plugin in @plugins

    # (key, fn) - Takes a key and a function.
    # (map) - Takes a map of keys and functions.
    add: ->
      arglen = arguments.length
      if arglen == 1
        throw "Expected a map object" unless $.isPlainObject(arguments[0])
        @add(key, fn) for own key, fn of arguments[0]
      else if arglen == 2
        @keys[@normalize(arguments[0])] = arguments[1]
      else
        throw "Wrong number of arguments to Keyboard#add"

    # (key) - Removes the key.
    # ([key]) - Array of keys to remove.
    remove: ->
      if $.isArray(arguments[0])
        @remove(key) for key in arguments[0]
      else
        delete @keys[@normalize(arguments[0])]

    start: =>
      @$el.on(@type, @onkeydown)

    stop: =>
      @$el.off(@type, @onkeydown)

    normalize: (key) ->
      keys = key.split('.')
      char = keys.pop()
      @buildKey(char, keys)

    buildKey: (key, specialKeys=[], delim='.') ->
      keys = specialKeys.sort()
      keys.push(key)
      keys.join(delim)

    onkeydown: (e) =>
      key = @keyFromEvent(e)
      fn = @keys[key]
      if fn
        e.preventDefault()
        fn()

    keyFromEvent: (e) ->
      key = Helpers.keyOf(e)
      specialKeys = []
      specialKeys.push('alt') if e.altKey
      specialKeys.push('ctrl') if e.ctrlKey
      specialKeys.push('shift') if e.shiftKey
      @buildKey(key, specialKeys)

  return Keyboard

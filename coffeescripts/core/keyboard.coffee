# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
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
    constructor: (@editor, @type) ->
      @keys = {}
      @editor.on("snapeditor.activate", @activate)
      @editor.on("snapeditor.deactivate", @deactivate)

    # (key, fn) - Takes a key and a function.
    # (map) - Takes a map of keys and functions.
    add: ->
      arglen = arguments.length
      if arglen == 1
        throw "Expected a map object" unless $.isPlainObject(arguments[0])
        @add(key, fn) for own key, fn of arguments[0]
      else if arglen == 2
        @keys[Helpers.normalizeKeys(arguments[0])] = arguments[1]
      else
        throw "Wrong number of arguments to Keyboard#add"

    # (key) - Removes the key.
    # ([key]) - Array of keys to remove.
    remove: ->
      if $.isArray(arguments[0])
        @remove(key) for key in arguments[0]
      else
        delete @keys[Helpers.normalizeKeys(arguments[0])]

    activate: =>
      @editor.$el.on(@type, @onkeydown)

    deactivate: =>
      @editor.$el.off(@type, @onkeydown)

    onkeydown: (e) =>
      key = Helpers.keysOf(e)
      fn = @keys[key]
      if fn
        e.preventDefault()
        fn()

define ["jquery.custom"], ($) ->
  class Plugins
    constructor: (@api, @defaultPlugins, @extraPlugins) ->
      @setup()

    setup: ->
      @keyboardShortcuts = {}
      @registerPlugin(plugin, true) for plugin in @defaultPlugins
      @registerPlugin(plugin, false) for plugin in @extraPlugins if @extraPlugins
      @normalizeKeyboardShortcuts()

    # Registers the plugin and adds any keyboard shortcuts.
    registerPlugin: (plugin, isDefault) ->
      klass = plugin.constructor.toString().match(/^function (.*)\(\) {/)
      plugin.register(@api)
      @addKeyboard(plugin) if plugin.getKeyboardShortcuts

    # Add the plugin's keyboard shortcuts to the list.
    addKeyboard: (plugin) ->
      $.extend(@keyboardShortcuts, plugin.getKeyboardShortcuts())

    # Take all the keyboard shortcuts that have actions as values and make it a
    # function that triggers that action on the API.
    normalizeKeyboardShortcuts: ->
      @setKeyboardShortcut(key, action) for key, action of @keyboardShortcuts

    # Set the key so that it triggers the API with the given action.
    setKeyboardShortcut: (key, action) ->
      @keyboardShortcuts[key] = => @api.trigger(action)

    # Returns an array of contexts.
    # ["table", ".custom_class"]
    getContexts: ->
      return @contexts if @contexts
      @contexts = []
      @contexts.push(context) for context, buttons of @getContextMenuButtons()
      return @contexts

    # Returns a mapping of keyboard shortcuts.
    # {
    #   "ctrl.b": <function>,
    #   "ctrl.i": <function>
    # }
    getKeyboardShortcuts: ->
      @setup() unless @keyboardShortcuts
      return @keyboardShortcuts

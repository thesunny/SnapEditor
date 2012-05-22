define ["jquery.custom", "core/ui/ui"], ($, UI) ->
  class Plugins
    constructor: (@api, @templates, @defaultPlugins, @extraPlugins, @defaultToolbarComponents, @customToolbarComponents) ->

    setup: ->
      @toolbarComponents =
        config: @customToolbarComponents or @defaultToolbarComponents
        available:
          "-": @getUI().gap()
      @contextMenuButtons = {}
      @keyboardShortcuts = {}
      @registerPlugin(plugin, true) for plugin in @defaultPlugins
      @registerPlugin(plugin, false) for plugin in @extraPlugins if @extraPlugins
      @normalizeKeyboardShortcuts()

    getUI: ->
      @ui or= new UI(@templates)

    # Registers the plugin and adds any UI components, actions, and keyboard
    # shortcuts.
    registerPlugin: (plugin, isDefault) ->
      plugin.register(@api)
      @addUIs(plugin, isDefault) if plugin.getUI
      @addActions(plugin) if plugin.getActions
      @addKeyboard(plugin) if plugin.getKeyboardShortcuts

    # Adds the UI components to the toolbar or contextmenu.
    addUIs: (plugin, isDefault) ->
      ui = plugin.getUI(@getUI())

      # Grab the toolbar default and remove it from the list.
      addDefault = !(isDefault or @customToolbarComponents)
      defaultComponent = ui["toolbar:default"]
      if !defaultComponent and addDefault
        throw "'toolbar:default' must be defined for plugin #{plugin}"
      delete ui["toolbar:default"]

      # Loop through each key and handle it.
      @addUI(key, value, if addDefault then defaultComponent else null) for key, value of ui

    # Adds the UI component to the toolbar or contextmenu.
    addUI: (key, component, defaultComponent = null) ->
      # Normalize the key to lowercase.
      key = key.toLowerCase()
      match = key.match(/^context:(.*)/)
      if match
        # Handle contextmenu UI.
        buttons = @contextMenuButtons[match[1]] or []
        @contextMenuButtons[match[1]] = buttons.concat($.makeArray(component))
      else
        # Handle toolbar UI.
        # Normalize the component to an array.
        @toolbarComponents.available[key] = $.makeArray(component)
        # If a default component is given, add it to the config, separated by a group break.
        if defaultComponent
          @toolbarComponents.config.push("|") unless @toolbarComponents.config.length == 0
          @toolbarComponents.config = @toolbarComponents.config.concat($.makeArray(defaultComponent))

    # Add all the plugin's actions.
    addActions: (plugin) ->
      # NOTE: We need the @addAction function because CoffeeScript uses the
      # same action variable throughout the entire loop. This causes binding
      # issues where the event handler is bound to the action variable.
      # Therefore, when the action variable changes, so does the event handler.
      # Basically, all the actions will point to the last action added. To
      # break this binding, we call a new function.
      @addAction(plugin, event, action) for event, action of plugin.getActions()

    # Add the action and bind it to the plugin.
    addAction: (plugin, event, action) ->
      @api.on("#{event}", -> action.apply(plugin, arguments))

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

    # Returns the toolbar buttons as an object.
    # {
    #   config: ["Bold", "-", "Italic", "|", "AlignRight"],
    #   available: {
    #     "Bold": <button object>,
    #     "Italic": <button object>,
    #     "AlignRight": <button object>,
    #     "-": <gap object>
    #   }
    # }
    getToolbarComponents: ->
      @setup() unless @toolbarComponents
      return @toolbarComponents

    # Returns the contextmenu buttons as an object.
    # {
    #   "table": [<button object>, ...],
    #   ".custom_class": [<button object>, ...]
    # }
    # TODO: No config yet. Maybe in a later version.
    getContextMenuButtons: ->
      @setup() unless @contextMenuButtons
      return @contextMenuButtons

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

  return Plugins

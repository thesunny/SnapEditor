define ["cs!jquery.custom", "cs!core/api", "cs!config/config.default", "cs!plugins/keyboard/keyboard"], ($, API, Defaults, Keyboard) ->
  class Editor
    defaultToolbarPlugins: []
    toolbarPlugins: []
    keyboardPlugins: []

    # Options:
    # * assets: an object that holds urls to assets
    #   * templates: the url of the HTML templates
    #   * css: the url of the CSS
    # * plugins: an array of editor plugins to add
    # * toolbar: toolbar config that replaces the default one
    constructor: (el, @config = {}) ->
      @$el = $(el)
      @api = new API(this)
      @loadAssets()
      @setupPlugins()

    getDefaults: ->
      @defaults or= Defaults

    loadAssets: ->
      @loadTemplates()
      @loadCSS()

    loadTemplates: ->
      $.ajax(
        url: @config.assets.templates,
        async: false,
        success: (html) => @$templates = $("<div/>").html(html)
      )

    loadCSS: ->
      if @config.assets.css
        $("<link href=\"#{@config.assets.css}\" rel=\"stylesheet\" type=\"text/css\">").appendTo("head")

    setupPlugins: ->
      @registerPlugins(@getDefaults().plugins, true)
      @registerPlugins(@config.plugins) if @config.plugins
      # Register the toolbar and keyboard after all the other plugins.
      @keyboard = new Keyboard(@keyboardPlugins, "keydown", @$el)
      @registerPlugin(@keyboard)

    registerPlugins: (plugins, isDefault = false) ->
      @registerPlugin(plugin, isDefault) for plugin in plugins

    registerPlugin: (plugin, isDefault = false) ->
      plugin.register(@api)
      @addToolbarPlugin(plugin, isDefault) if plugin.getToolbar
      @addKeyboardPlugin(plugin) if plugin.getKeyboardShortcuts
      # TODO: contextmenu

    # All the available toolbar buttons will be squeezed into a single object.
    addToolbarPlugin: (plugin, isDefault = false) ->
      throw "The toolbar plugin is missing a default: #{plugin}, #{isDefault}" unless plugin.getDefaultToolbar
      if isDefault
        @defaultToolbarPlugins.push(plugin)
      else
        @toolbarPlugins.push(plugin)

    addKeyboardPlugin: (plugin) ->
      @keyboardPlugins.push(plugin)

    activate: ->
      @api.trigger("activate.editor")
      # TODO: Is this needed?
      @api.trigger("ready.editor")

    deactivate: ->
      @api.trigger("deactivate.editor")

    update: ->
      @api.trigger("update.editor")

    contents: ->
      @$el.html()

  return Editor

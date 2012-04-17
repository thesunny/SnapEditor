define ["cs!jquery.custom", "cs!core/api", "cs!config/config.default", "cs!plugins/toolbar/toolbar", "cs!plugins/keyboard/keyboard"], ($, API, Default, Toolbar, Keyboard) ->
  class Editor
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
      # All the available toolbar buttons will be squeezed into a single object.
      @registerPlugins(Default.plugins.concat(@config.plugins or []))
      # Register the toolbar and keyboard after all the other plugins.
      @toolbar = new Toolbar(@toolbarPlugins, @$templates, @config.toolbar or Default.toolbar)
      @keyboard = new Keyboard(@keyboardPlugins, "keydown", @$el)
      @registerPlugins([@toolbar, @keyboard])

    registerPlugins: (plugins) ->
      @registerPlugin(plugin) for plugin in plugins

    registerPlugin: (plugin) ->
      plugin.register(@api)
      @addToolbarPlugin(plugin) if plugin.getToolbar
      @addKeyboardPlugin(plugin) if plugin.getKeyboardShortcuts
      # TODO: contextmenu

    addToolbarPlugin: (plugin) ->
      throw "The toolbar plugin is missing a default" unless plugin.getDefaultToolbar
      @toolbarPlugins.push(plugin)

    addKeyboardPlugin: (plugin) ->
      @keyboardPlugins.push(plugin)

    activate: ->
      @api.trigger("activate.editor")
      @api.trigger("ready.editor")

    deactivate: ->
      @api.trigger("deactivate.editor")

    update: ->
      @api.trigger("update.editor")

    contents: ->
      @$el.html()

  return Editor

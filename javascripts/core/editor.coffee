define ["cs!jquery.custom", "cs!core/api", "cs!config/config.default", "cs!plugins/toolbar/toolbar"], ($, API, Default, Toolbar) ->
  class Editor
    # Options:
    # * assets: an object that holds urls to assets
    #   * templates: the url of the HTML templates
    #   * css: the url of the CSS
    # * plugins: an array of editor plugins to add
    # * toolbar: toolbar config that replaces the default one
    constructor: (el, @config = {}) ->
      @$el = $(el)
      @api = new API(this)
      @toolbarConfig = @config.toolbar or Default.toolbar
      # All the available toolbar buttons will be squeezed into a single object.
      @toolbarPlugins = []
      @registerPlugins(Default.plugins.concat(@config.plugins or []))

    registerPlugins: (plugins) ->
      @registerPlugin(plugin) for plugin in plugins

    registerPlugin: (plugin) ->
      plugin.register(@api)
      @addToolbarPlugin(plugin) if plugin.getToolbar
      # TODO: contextmenu, keyboard

    addToolbarPlugin: (plugin) ->
      throw "The toolbar plugin is missing a default" unless plugin.getDefaultToolbar
      @toolbarPlugins.push(plugin)

    getTemplates: ->
      unless @$templates
        $.ajax(url: @config.assets.templates, async: false, success: (html) =>
          @$templates = $("<div/>").html(html)
        )
      return @$templates

    setupToolbar: ->
      @toolbar = new Toolbar(@toolbarPlugins, @getTemplates(), @toolbarConfig)
      @toolbar.register(@api)

    activate: ->
      @api.trigger("activate.editor")
      @setupToolbar()
      @api.trigger("ready.editor")

    update: ->

    contents: ->

  return Editor

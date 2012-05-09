define ["jquery.custom", "core/api", "core/plugins", "core/keyboard", "core/contexts", "core/contextmenu", "core/whitelist/whitelist"], ($, API, Plugins, Keyboard, Contexts, ContextMenu, Whitelist) ->
  class Editor
    # Options:
    # * assets: an object that holds urls to assets
    #   * templates: the url of the HTML templates
    #   * css: the url of the CSS
    # * plugins: an array of editor plugins to add
    # * toolbar: toolbar config that replaces the default one
    constructor: (el, @defaults, @config = {}) ->
      @$el = $(el)
      @whitelist = new Whitelist(@defaults.whitelist)
      @api = new API(this)
      @loadAssets()
      @plugins = new Plugins(@api, @$templates, @defaults.plugins, @config.plugins, @defaults.toolbar, @config.toolbar)
      @keyboard = new Keyboard(@api, @plugins.getKeyboardShortcuts(), "keydown")
      @contexts = new Contexts(@api, @plugins.getContexts())
      @contextmenu = new ContextMenu(@api, @plugins.getContextMenuButtons())

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

    activate: ->
      @api.trigger("activate.editor")
      # TODO: Is this needed?
      @api.trigger("ready.editor")

    deactivate: ->
      @api.trigger("deactivate.editor")

    update: ->
      @api.trigger("update.editor")

    contents: ->
      # Clean the content before returning it.
      @api.clean(@api.el.firstChild, @api.el.lastChild)
      @$el.html()

  return Editor

define ["jquery.custom", "core/helpers", "core/api", "core/plugins", "core/keyboard", "core/contexts", "core/contextmenu/contextmenu", "core/whitelist/whitelist"], ($, Helpers, API, Plugins, Keyboard, Contexts, ContextMenu, Whitelist) ->
  class Editor
    # Options:
    # * path: path to the snapeditor directory
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
      @contextmenu = new ContextMenu(@api, @$templates, @plugins.getContextMenuButtons())

    loadAssets: ->
      @loadTemplates()
      @loadCSS()

    loadTemplates: ->
      $.ajax(
        url: @api.assets.template("snapeditor.html")
        async: false,
        success: (html) => @$templates = $("<div/>").html(html)
      )

    loadCSS: ->
      # Don't use a <link> tag because it loads asynchronously. Attaching to
      # the onload is not reliable. This hack loads the CSS through AJAX
      # synchronously and dumps the styles into a <style> tag.
      $.ajax(
        url: @api.assets.stylesheet("snapeditor.css")
        async: false,
        success: (css) -> Helpers.insertStyles(css)
      )

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
      regexp = new RegExp(Helpers.zeroWidthNoBreakSpaceUnicode, "g")
      @$el.html().replace(regexp, "")

  return Editor

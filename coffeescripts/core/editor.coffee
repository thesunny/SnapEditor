define ["jquery.custom", "core/helpers", "core/assets", "core/api", "core/plugins", "core/keyboard", "core/contextmenu/contextmenu", "core/whitelist/whitelist"], ($, Helpers, Assets, API, Plugins, Keyboard, ContextMenu, Whitelist) ->
# NOTE: Removed from the list above. May need it later.
# "core/contexts"
# Contexts
  class Editor
    # el - string id or DOM element
    # defaults - default config
    # config - user config
    #   * path: path to the snapeditor directory
    #   * plugins: an array of editor plugins to add
    #   * toolbar: toolbar config that replaces the default one
    #   * whitelist: object specifying the whitelist
    #   * lang: language (default: "en")
    #   * onSave: callback for saving (return true or error message)
    constructor: (el, @defaults, @config = {}) ->
      @unsupported = false
      # Transform the string into a CSS id selector.
      el = "#" + el if typeof el == "string"
      @$el = $(el)
      @prepareConfig()
      @assets = new Assets(@config.path)
      @whitelist = new Whitelist(@config.cleaner.whitelist)
      @loadAssets()
      @api = new API(this)
      @plugins = new Plugins(@api, @$templates, @defaults.plugins, @config.plugins, @defaults.toolbar, @config.toolbar)
      @keyboard = new Keyboard(@api, @plugins.getKeyboardShortcuts(), "keydown")
      #@contexts = new Contexts(@api, @plugins.getContexts())
      @contextmenu = new ContextMenu(@api, @$templates, @plugins.getContextMenuButtons())
      @api.trigger("ready.plugins")

    prepareConfig: ->
      @config.cleaner or= {}
      @config.cleaner.whitelist or = @defaults.cleaner.whitelist
      @config.cleaner.ignore or= @defaults.cleaner.ignore
      @config.lang or= @defaults.lang
      @config.atomic or= {}
      @config.atomic.classname or= @defaults.atomic.classname

      # Add the atomic classname to the cleaner's ignore list.
      @config.cleaner.ignore.push(@config.atomic.classname)

    loadAssets: ->
      @loadLang()
      @loadTemplates()
      @loadCSS()

    loadLang: ->
      $.ajax(
        url: @assets.lang(@config.lang),
        async: false,
        success: (json) => @lang = json
      )

    loadTemplates: ->
      $.ajax(
        url: @assets.template("snapeditor.html")
        async: false,
        success: (html) => @$templates = $("<div/>").html(html)
      )

    loadCSS: ->
      # Don't use a <link> tag because it loads asynchronously. Attaching to
      # the onload is not reliable. This hack loads the CSS through AJAX
      # synchronously and dumps the styles into a <style> tag.
      $.ajax(
        url: @assets.stylesheet("snapeditor.css")
        async: false,
        success: (css) -> Helpers.insertStyles(css)
      )

    activate: ->
      @api.trigger("activate.editor")
      @api.trigger("ready.editor")

    tryDeactivate: ->
      @api.trigger("tryDeactivate.editor")

    deactivate: ->
      @api.trigger("deactivate.editor")

    update: ->
      @api.trigger("update.editor")

    getContents: ->
      # Clean the content before returning it.
      @api.clean(@$el[0].firstChild, @$el[0].lastChild)
      regexp = new RegExp(Helpers.zeroWidthNoBreakSpaceUnicode, "g")
      @$el.html().replace(regexp, "")

    setContents: (html) ->
      @$el.html(html)
      @api.clean(@$el[0].firstChild, @$el[0].lastChild)

    save: ->
      saved = "No save callback defined."
      saved = @config.onSave(@getContents()) if @config.onSave
      return saved

  return Editor

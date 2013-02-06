define ["jquery.custom", "core/browser", "core/helpers", "core/assets", "core/api", "core/plugins", "core/keyboard", "core/contextmenu/contextmenu", "core/whitelist/whitelist"], ($, Browser, Helpers, Assets, API, Plugins, Keyboard, ContextMenu, Whitelist) ->
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
      SnapEditor.DEBUG("Webkit: #{Browser.isWebkit}")
      SnapEditor.DEBUG("Gecko: #{Browser.isGecko}")
      SnapEditor.DEBUG("Gecko1: #{Browser.isGecko1}")
      SnapEditor.DEBUG("IE: #{Browser.isIE}")
      SnapEditor.DEBUG("IE7: #{Browser.isIE7}")
      SnapEditor.DEBUG("IE8: #{Browser.isIE8}")
      SnapEditor.DEBUG("IE9: #{Browser.isIE9}")
      SnapEditor.DEBUG("W3C Ranges: #{Browser.hasW3CRanges}")
      SnapEditor.DEBUG("Supported: #{Browser.isSupported}")

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
      SnapEditor.DEBUG("Finished: Plugins are a go")
      @api.trigger("snapeditor.plugins_ready")

    prepareConfig: ->
      SnapEditor.DEBUG("Start: Prepare Config")
      @config.cleaner or= {}
      @config.cleaner.whitelist or = @defaults.cleaner.whitelist
      @config.cleaner.ignore or= @defaults.cleaner.ignore
      @config.lang or= @defaults.lang
      @config.atomic or= {}
      @config.atomic.classname or= @defaults.atomic.classname
      @config.atomic.selectors = [".#{@config.atomic.classname}"]
      @config.eraseHandler or= {}
      @config.eraseHandler.delete or= @defaults.eraseHandler.delete
      @config.widget or= {}
      @config.widget.classname or= @defaults.widget.classname

      # Add selectors to the atomic's selectors list.
      @config.atomic.selectors.push(".#{@config.widget.classname}")
      # Add selectors to the cleaner's ignore list.
      @config.cleaner.ignore = @config.cleaner.ignore.concat(@config.atomic.selectors)
      # Add selectors to the eraseHandler's delete list.
      @config.eraseHandler.delete = @config.eraseHandler.delete.concat(@config.atomic.selectors)

      SnapEditor.DEBUG("End: Prepare Config")

    loadAssets: ->
      @loadLang()
      @loadTemplates()
      @loadCSS()

    loadLang: ->
      SnapEditor.DEBUG("Start: Load Lang")
      $.ajax(
        url: @assets.lang(@config.lang),
        async: false,
        success: (json) => @lang = json
      )
      SnapEditor.DEBUG("End: Load Lang")

    loadTemplates: ->
      SnapEditor.DEBUG("Start: Load Templates")
      $.ajax(
        url: @assets.template("snapeditor.html")
        async: false,
        success: (html) => @$templates = $("<div/>").html(html)
      )
      SnapEditor.DEBUG("End: Load Templates")

    loadCSS: ->
      SnapEditor.DEBUG("Start: Load CSS")
      # Don't use a <link> tag because it loads asynchronously. Attaching to
      # the onload is not reliable. This hack loads the CSS through AJAX
      # synchronously and dumps the styles into a <style> tag.
      $.ajax(
        url: @assets.stylesheet("snapeditor.css")
        async: false,
        success: (css) -> Helpers.insertStyles(css)
      )
      SnapEditor.DEBUG("End: Load CSS")

    domEvents: [
      "mouseover"
      "mouseout"
      "mousedown"
      "mouseup"
      "click"
      "dblclick"
      "keydown"
      "keyup"
      "keypress"
    ]

    outsideDOMEvents: [
      "mousedown"
      "mouseup"
      "click"
      "dblclick"
      "keydown"
      "keyup"
      "keypress"
    ]

    # NOTE: This is for the following the functions.
    # - handleDOMEvent
    # - handleDocumentEvent
    # We want to pass the original DOM event through to the handler but with
    # our custom data and the event type with "snapeditor" as the namespace.
    # However, simply doing @api.trigger("snapeditor.event", e) doesn't work
    # because the handler would see it as function(event, e). We want
    # function(e) instead. To get around this, we pass e directly to the
    # trigger. This forces jQuery to use e instead of creating a new event.
    # However, jQuery uses e's type as the event name to trigger. Hence, we
    # modify it to include the "snapeditor" namespace to trick it.
    # Also, the way jQuery namespaces work are more like CSS classes. They
    # aren't true namespaces.
    # e.g.
    #   "snapeditor.outside.click" != snapeditor -> outside -> click
    #   "snapeditor.outside.click == snapeditor -> outside
    #                                snapeditor -> click

    # Add custom SnapEditor data to the event.
    handleDOMEvent: (e) =>
      @addCustomDataToEvent(e)
      e.type = "snapeditor.#{e.type}"
      @api.trigger(e)

    handleDocumentEvent: (e) =>
      @addCustomDataToEvent(e)
      type = e.type
      e.type = "snapeditor.document_#{type}"
      @api.trigger(e)
      if $(e.target).closest(@$el).length == 0
        e.type = "snapeditor.outside_#{type}"
        @api.trigger(e)

    addCustomDataToEvent: (e) ->
      if e.pageX
        coords = Helpers.transformCoordinatesRelativeToOuter(
          x: e.pageX
          y: e.pageY
          e.target
        )
        e.outerPageX = coords.x
        e.outerPageY = coords.y

    # Attaches the given event handlers to the given events on all documents on
    # the page.
    #
    # Arguments:
    # * event, event handler
    # * map
    onDocument: ->
      args = arguments
      $document = $(document)
      $document.on.apply($document, args)
      $("iframe").each(->
        $doc = $(this.contentWindow.document)
        $doc.on.apply($doc, args)
      )

    # Detaches events from all documents on the page.
    # Given an event handler, detaches only the given event handler.
    # Given only an event, detaches all event handlers for the given event.
    #
    # Arguments:
    # * event, event handler
    # * event
    # * map
    offDocument: ->
      args = arguments
      $document = $(document)
      $document.off.apply($document, args)
      $("iframe").each(->
        $doc = $(this.contentWindow.document)
        $doc.off.apply($doc, args)
      )

    attachDOMEvents: ->
      @$el.on(event, @handleDOMEvent) for event in @domEvents
      @onDocument(event, @handleDocumentEvent) for event in @outsideDOMEvents

    detachDOMEvents: ->
      @$el.off(event, @handleDOMEvent) for event in @domEvents
      @offDocument(event, @handleDocumentEvent) for event in @outsideDOMEvents

    activate: ->
      @attachDOMEvents()
      @api.trigger("snapeditor.activate")
      @api.trigger("snapeditor.ready")

    tryDeactivate: ->
      @api.trigger("snapeditor.tryDeactivate")

    deactivate: ->
      @detachDOMEvents()
      @api.trigger("snapeditor.deactivate")

    update: ->
      @api.trigger("snapeditor.update")

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

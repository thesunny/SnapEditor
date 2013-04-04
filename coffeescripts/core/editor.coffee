define ["jquery.custom", "core/browser", "core/helpers", "core/events", "core/assets", "core/range", "core/exec_command/exec_command", "core/keyboard", "core/whitelist/whitelist", "core/api"], ($, Browser, Helpers, Events, Assets, Range, ExecCommand, Keyboard, Whitelist, API) ->
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
    #   * onSave: callback for saving (return true or error message)
    constructor: (el, @defaults, @config = {}) ->
      # Delay the initialization of the editor until the document is ready.
      $(Helpers.pass(@init, [el], this))

    # Perform the actual initialization of the editor.
    init: (el) =>
      @unsupported = false

      # Transform the string into a CSS id selector.
      el = "#" + el if typeof el == "string"

      # Set up DOM related things.
      @$el = $(el)
      @el = @$el[0]
      @doc = Helpers.getDocument(@el)
      @win = Helpers.getWindow(@el)

      # Setup the config.
      @prepareConfig()

      # Create needed objects.
      @assets = new Assets(@config.path or SnapEditor.getPath())
      @whitelist = new Whitelist(@config.cleaner.whitelist)
      @keyboard = new Keyboard(this, "keydown")
      @execCommand = new ExecCommand(this)

      # Deal with new plugins.
      @setupPlugins()
      @setupCommands()

      # Delegate Public API functions.
      @delegatePublicAPIFunctions()

      # Instantiate the API.
      @api = new API(this)

      # The default is to deactivate immediately. However, to accommodate
      # plugins such as the Save plugin, this can be disabled and handled in a
      # customized way. Use #disableImmediateDeactivate.
      @on("snapeditor.try_deactivate", @deactivate)

      # Ready.
      @trigger("snapeditor.plugins_ready")

    prepareConfig: ->
      @config.toolbar or= @defaults.toolbar
      @config.plugins or= @defaults.plugins
      @config.lang = SnapEditor.lang
      @config.cleaner or= {}
      @config.cleaner.whitelist or = @defaults.cleaner.whitelist
      @config.cleaner.ignore or= @defaults.cleaner.ignore
      @config.atomic or= {}
      @config.atomic.classname or= @defaults.atomic.classname
      @config.atomic.selectors = [".#{@config.atomic.classname}"]
      @config.eraseHandler or= {}
      @config.eraseHandler.delete or= @defaults.eraseHandler.delete

      # Add the atomic classname to the cleaner's ignore list.
      @config.cleaner.ignore = @config.cleaner.ignore.concat(@config.atomic.selectors)
      # Add the atomic selectors to the erase handler's delete list.
      @config.eraseHandler.delete = @config.eraseHandler.delete.concat(@config.atomic.selectors)

    # Creates the plugins object and attaches the relevant events.
    setupPlugins: ->
      allPlugins = SnapEditor.getAllPlugins()
      @plugins = {}
      for name in @config.plugins
        plugin = allPlugins[name]
        throw "Plugin does not exist: #{name}" unless plugin
        @plugins[name] = plugin
        for key, fn of plugin.events or {}
          @on("snapeditor.#{Helpers.camelToSnake(key)}", fn)

    # Creates the commands object including the ones in the plugins.
    setupCommands: ->
      @commands = SnapEditor.getAllCommands()
      for name, plugin of @plugins
        @commands[key] = command for key, command of plugin.commands || {}

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
    # However, simply doing @trigger("snapeditor.event", e) doesn't work
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
      e.type = "snapeditor.#{e.type}"
      @trigger(e)

    handleDocumentEvent: (e) =>
      unless e.type == "snapeditor"
        type = e.type
        e.type = "snapeditor.document_#{type}"
        @trigger(e)
        if $(e.target).closest(@$el).length == 0
          e.type = "snapeditor.outside_#{type}"
          @trigger(e)

    addCustomDataToEvent: (e) ->
      e.api = @api
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

    ############################################################################
    #
    # PUBLIC API
    #
    ############################################################################

    delegatePublicAPIFunctions: ->
      Helpers.delegate(this, "whitelist", "isAllowed", "getReplacement", "getNext")
      Helpers.delegate(this, "getRange()",
        "isValid", "isCollapsed", "isImageSelected", "isStartOfElement", "isEndOfElement",
        "getParentElement", "getParentElements", "getText",
        "collapse", "unselect", "keepRange", "moveBoundary",
        "insert", "surroundContents", "delete"
      )
      Helpers.delegate(this, "getBlankRange()", "selectNodeContents", "selectEndOfElement")
      Helpers.delegate(this, "execCommand",
        "formatBlock", "formatInline", "align", "indent", "outdent",
        "insertUnorderedList", "insertOrderedList", "insertHorizontalRule", "insertLink"
      )

    #
    # EVENTS
    #

    # Activate the editor.
    activate: ->
      @attachDOMEvents()
      @trigger("snapeditor.activate")
      @trigger("snapeditor.ready")

    # Try to deactivate the editor.
    tryDeactivate: ->
      @trigger("snapeditor.try_deactivate")

    # Disable the immediate deactivation of the editor.
    disableImmediateDeactivate: ->
      @off("snapeditor.try_deactivate", @deactivate)

    # Deactivate the editor.
    deactivate: =>
      @detachDOMEvents()
      @trigger("snapeditor.deactivate")

    # Update the editor.
    update: ->
      @trigger("snapeditor.update")

    # Clean the editor.
    clean: ->
      @trigger("snapeditor.clean", arguments)

    # Save the contents of the editor.
    save: ->
      saved = "No save callback defined."
      saved = @config.onSave(@getContents()) if @config.onSave
      saved

    #
    # CONTENTS
    #

    # Returns the contents of the editor after cleaning.
    getContents: ->
      # Clean the content before returning it.
      @clean(@el.firstChild, @el.lastChild)
      regexp = new RegExp(Helpers.zeroWidthNoBreakSpaceUnicode, "g")
      @$el.html().replace(regexp, "")

    # Sets the contents of the editor and cleans it.
    setContents: (html) ->
      @$el.html(html)
      @clean(@el.firstChild, @el.lastChild)

    #
    # DOM
    #

    # Shortcut to the doc's createElement().
    createElement: (name) ->
      @doc.createElement(name)

    # Shortcut to the doc's createTextNode().
    createTextNode: (text) ->
      @doc.createTextNode(text)

    # Shortcut to find elements in the doc. Always returns an array.
    find: (selector) ->
      $(@doc).find(selector).toArray()

    # Inserts the given styles into the head of the document.
    # The id is used to ensure duplicate styles are not added.
    insertStyles: (id, styles) ->
      SnapEditor.insertStyles(id, styles)

    #
    # KEYBOARD
    #

    addKeyboardShortcut: (key, fn) ->
      @keyboard.add(key, fn)

    removeKeyboardShortcut: (key) ->
      @keyboard.remove(key)

    #
    # WHITELIST
    #

    # Gets the default block from the whitelist.
    getDefaultBlock: ->
      @whitelist.getDefaults()["*"].getElement(@doc)

    #
    # ASSETS
    #

    imageAsset: (filename) ->
      @assets.image(filename)

    flashAsset: (filename) ->
      @assets.flash(filename)

    #
    # RANGE
    #

    # Gets the current selection if el is not given.
    # Otherwise returns the range that represents the el.
    # If a selection does not exist, use #getBlankRange().
    getRange: (el) ->
      new Range(@el, el or @win)

    # Get a blank range. This is here in case a selection does not exist.
    # If a selection exists, use #getRange().
    getBlankRange: ->
      new Range(@el)

    # Select the given arg. If no arg is given, selects the current selection.
    # NOTE: This is not directly delegated to the Range object because it is
    # slightly different. This takes a given argument and selects it.
    # Arguments:
    # * arg - Either a SnapEditor Range or DOM element.
    select: (arg) ->
      if arg and arg.collapse
        range = arg
      else
        range = @getRange(arg)
      range.select()

    # Add the coordinates relative to the outer window.
    getCoordinates: (range) ->
      range or= @getRange()
      coords = range.getCoordinates()
      coords.outer = $.extend({}, Helpers.transformCoordinatesRelativeToOuter(coords, @el))
      coords

  Helpers.include(Editor, Events)
  # Override the default trigger() from Events so that we can add custom data
  # to the event being triggered.
  Editor.prototype.elTrigger = Editor.prototype.trigger
  Editor.prototype.trigger = (event, params = []) ->
    e = if typeof event == "string" then $.Event(event) else event
    @addCustomDataToEvent(e)
    @elTrigger(e, params)

  return Editor

# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/browser", "core/helpers", "core/events", "core/assets", "core/range", "core/exec_command/exec_command", "core/keyboard", "core/whitelist/whitelist", "core/widget/widgets_manager", "core/api", "core/toolbar/toolbar.button"], ($, Browser, Helpers, Events, Assets, Range, ExecCommand, Keyboard, Whitelist, WidgetsManager, API, ToolbarButton) ->
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
    constructor: (el, defaults, config = {}) ->
      @defaults = Helpers.deepClone(defaults)
      @config = Helpers.deepClone(config)
      # Delay the initialization of the editor until the document is ready.
      $(Helpers.pass(@init, [el], this))

    # Perform the actual initialization of the editor.
    init: (el) =>
      @unsupported = false
      @enabled = true

      # Transform the string into a CSS id selector.
      el = "#" + el if typeof el == "string"

      # Set up DOM related things.
      @$el = $(el)
      @el = @$el[0]
      @doc = Helpers.getDocument(@el)
      @win = Helpers.getWindow(@el)

      # Prepare the config.
      @prepareConfig()

      # Create needed objects.
      @assets = new Assets(@config.path or SnapEditor.getPath())
      @whitelist = new Whitelist(@config.cleaner.whitelist)
      @keyboard = new Keyboard(this, "keydown")
      @execCommand = new ExecCommand(this)
      @widgetsManager = new WidgetsManager(this, @config.widget.classname)

      # Instantiate the API.
      @api = new API(this)
      @api.on("snapeditor.activate", @attachDOMEvents)
      @api.on("snapeditor.deactivate", @detachDOMEvents)

      # Deal with plugins.
      @includeStyles()
      @includeButtons()
      @includeBehaviours()
      @includeShortcuts()
      @includeWhitelistDefaults()

      # Delegate Public API functions.
      @delegatePublicAPIFunctions()

      # We set the onTryDeactivate default here to give every one else a
      # chance to set it first (namely the plugin).
      @config.onTryDeactivate or= @deactivate

      # Ready.
      @trigger("snapeditor.plugins_ready")

    prepareConfig: ->
      @config.styles or= @defaults.styles
      @config.toolbar or= @defaults.toolbar
      if typeof @config.toolbar == "string"
        buttonName = @config.toolbar
        buttonOptions = SnapEditor.buttons[@config.toolbar]
        throw "Button has not been defined: #{@config.toolbar}" unless buttonOptions
        throw "Button must have items in order to be used as a toolbar: #{@config.toolbar}" unless buttonOptions.items
      @config.toolbar = new ToolbarButton(buttonName or "snapeditor_anonymous_toolbar", buttonOptions or @config.toolbar)
      @config.behaviours or= @defaults.behaviours
      @config.shortcuts or= @defaults.shortcuts
      @config.lang = $.extend({}, SnapEditor.lang)
      @config.activateByLinks = @defaults.activateByLinks
      @config.cleaner or= {}
      @config.cleaner.whitelist or = @defaults.cleaner.whitelist
      @config.cleaner.ignore or= @defaults.cleaner.ignore
      @config.eraseHandler or= {}
      @config.eraseHandler.delete or= @defaults.eraseHandler.delete
      @config.atomic or= {}
      @config.atomic.classname or= @defaults.atomic.classname
      @config.atomic.selectors = [".#{@config.atomic.classname}"]
      @config.widget or= {}
      @config.widget.classname or= @defaults.widget.classname

      # Add selectors to the atomic's selectors list.
      @config.atomic.selectors.push(".#{@config.widget.classname}")
      # Add selectors to the cleaner's ignore list.
      @config.cleaner.ignore = @config.cleaner.ignore.concat(@config.atomic.selectors)
      # Add selectors to the eraseHandler's delete list.
      @config.eraseHandler.delete = @config.eraseHandler.delete.concat(@config.atomic.selectors)

    includeStyles: ->
      @styleButtons = {}
      @includeStyle(selector) for selector in @config.styles

    includeStyle: (selector) ->
      key = SnapEditor.getStyleKey(selector)
      @styleButtons[key] = SnapEditor.buttons[key] or throw "Style does not exist: #{selector}"

    includeButtons: ->
      @includeButton(name) for name in @config.toolbar.getItems(api: @api)

    includeButton: (name) ->
      unless name == "|"
        buttonOptions = SnapEditor.buttons[name]
        throw "Button does not exist: #{name}" unless buttonOptions
        button = new ToolbarButton(name, buttonOptions)
        button.onInclude(api: @api)
        @includeButton(name) for name in button.getItems(api: @api)

    includeBehaviours: ->
      @config.behaviours = Helpers.uniqueArray(@config.behaviours)
      for name in @config.behaviours
        behaviour = SnapEditor.behaviours[name]
        throw "Behaviour does not exist: #{name}" unless behaviour
        for event, action of behaviour
          actionFn = action
          actionFn = SnapEditor.actions[action] if typeof action == "string"
          @on("snapeditor.#{Helpers.camelToSnake(event.replace(/^on/, ""))}", actionFn)

    includeShortcuts: ->
      @actionShortcuts = {}
      @config.shortcuts = Helpers.uniqueArray(@config.shortcuts)
      for name in @config.shortcuts
        shortcut = SnapEditor.shortcuts[name]
        throw "Shortcut doe not exist: #{name}" unless shortcut
        throw "Shortcut is missing a key: #{name}" unless shortcut.key
        throw "Shortcut is missing an action: #{name}" unless shortcut.action
        # The generateActionFn() is required due to scoping issues.
        self = this
        generateActionFn = (action) ->
          ->
            e = $.Event(action)
            e.api = self.api
            self.api.execAction(action, e)
        @addKeyboardShortcut(shortcut.key, generateActionFn(shortcut.action))
        # If the shortcut action is a string, relate the shortcut to an action
        # if available.
        @actionShortcuts[shortcut.action] = shortcut.key if typeof shortcut.action == "string"

    includeWhitelistDefaults: ->
      @addWhitelistRule("*", SnapEditor.getSelectorFromStyleKey(@getStyleButtonsByTag("style-block")[0] or "p > p"))

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
        e.outerPageX = e.pageX
        e.outerPageY = e.pageY

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

    # Place a shim over each iframe on the page except for the given ignored
    # iframe.
    addIFrameShims: (ignoreIFrame) ->
      @iframeShims = []
      self = this
      $("iframe").each(->
        unless this == ignoreIFrame
          $iframe = $(this)
          $shim = $("<div/>").css(
            position: "absolute"
            zIndex: parseInt($iframe.css("zIndex")) + 1
          ).appendTo("body")
          self.positionIFrameShim($iframe, $shim)
          self.iframeShims.push(
            $iframe: $iframe
            $shim: $shim
          )
      )
      # In IE, a div over an iframe doesn't block out the iframe. The div does
      # indeed overlay the iframe, but you can still click through the div
      # into the iframe. A background must be set to prevent this. However, if
      # a solid background is set, you can't see the contents of the iframe
      # anymore. Hence, we make the background transparent.
      # Unfortunately, we could not add this code in the above call to
      # each(). When the filter was applied to the first div, all subsequent
      # calls to getCoordinates() returned the top of the window as the top
      # coordinate. This positioned all subsequent divs in the wrong place. To
      # avoid this, we apply the filter after positioning the divs.
      if Browser.isIE
        for iframeShim in @iframeShims
          iframeShim.$shim.css(
            backgroundColor: "white"
            filter: "alpha(opacity=1)" # IE8/9
            opacity: 0.01 # IE10
          )
      @on("snapeditor.cleaner_finished", @repositionIFrameShims)

    # Remove all the iframe shims.
    removeIFrameShims: ->
      @off("snapeditor.cleaner_finished", @repositionIFrameShims)
      iframeShim.$shim.remove() for iframeShim in @iframeShims

    # Reposition all the iframe shims.
    repositionIFrameShims: =>
      @positionIFrameShim(iframeShim.$iframe, iframeShim.$shim) for iframeShim in @iframeShims

    # Position the shim over the iframe.
    positionIFrameShim: ($iframe, $shim) ->
      coords = $iframe.getCoordinates()
      $shim.css(
        top: coords.top
        left: coords.left
        width: coords.width
        height: coords.height
      )

    attachDOMEvents: =>
      @$el.on(event, @handleDOMEvent) for event in @domEvents
      @addIFrameShims()
      @onDocument(event, @handleDocumentEvent) for event in @outsideDOMEvents

    detachDOMEvents: =>
      @$el.off(event, @handleDOMEvent) for event in @domEvents
      @removeIFrameShims()
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
        "unselect", "keepRange",
        "insert", "surroundContents", "delete"
      )
      Helpers.delegate(this, "getBlankRange()", "selectElementContents", "selectEndOfElement")
      Helpers.delegate(this, "execCommand",
        "styleBlock", "formatInline", "align", "indent", "outdent",
        "insertUnorderedList", "insertOrderedList", "insertHorizontalRule", "insertLink"
      )
      Helpers.delegate(this, "widgetsManager", "insertWidget")

    #
    # EVENTS
    #

    # Enable the editor.
    enable: ->
      @enabled = true

    # Disable the editor.
    disable: ->
      @enabled = false

    # Returns true if the editor is enabled. False otherwise.
    isEnabled: ->
      @enabled

    # Activate the editor.
    activate: ->
      @execAction("activate", api: @api)

    tryDeactivate: ->
      @api.config.onTryDeactivate(api: @api)

    # Deactivate the editor.
    deactivate: =>
      @execAction("deactivate", api: @api)

    # Update the editor.
    update: ->
      @trigger("snapeditor.update")

    # Clean the editor.
    clean: ->
      @trigger("snapeditor.clean", arguments)

    #
    # CONTENTS
    #

    # Returns the contents of the editor after cleaning and changing unicode
    # zero-width no-break spaces to HTML entities.
    getContents: ->
      # Clean the content before returning it.
      @clean(@el.firstChild, @el.lastChild)
      regexp = new RegExp(Helpers.zeroWidthNoBreakSpaceUnicode, "g")
      @$el.html().replace(regexp, Helpers.zeroWidthNoBreakSpace)

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
      @$el.find(selector).toArray()

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
    # BUTTONS
    #

    # Returns an array of button strings where the button contains the given
    # tag.
    getStyleButtonsByTag: (tag) ->
      buttons = []
      for own key, button of @styleButtons
        buttons.push(key) if button.tags and $.inArray(tag, button.tags) > -1
      buttons

    #
    # WHITELIST
    #

    # Arguments:
    # key and rule
    # or
    # object of keys/rules
    addWhitelistRule: ->
      @whitelist.add.apply(@whitelist, arguments)

    # Arguments:
    # rule - whitelist rule
    # tags - array of tags
    addWhitelistGeneralRule: ->
      @whitelist.addGeneralRule.apply(@whitelist, arguments)

    # Gets the default block from the whitelist.
    getDefaultBlock: ->
      @whitelist.getDefaultFor("*", @doc)

    #
    # ASSETS
    #

    imageAsset: (filename) ->
      @assets.image(filename)

    flashAsset: (filename) ->
      @assets.flash(filename)

    #
    # DIALOGS
    #

    openDialog: ->
      type = arguments[0]
      event = arguments[1]
      args = [].slice.apply(arguments, [2])
      SnapEditor.openDialog(type, event, args)

    closeDialog: (type) ->
      SnapEditor.closeDialog(type)

    #
    # ACTIONS
    #

    # Executes the action corresponding.
    # If a function is given, executes the function.
    # If a string is given, finds the corresponding action and executes it.
    # By convention, the first argument of args should be a SnapEditor event
    # object.
    execAction: (action, args...) ->
      actionFn = action
      actionFn = SnapEditor.actions[action] if typeof action == "string"
      throw "Action does not exist: #{action}" unless actionFn
      actionFn.apply(@win, args)

    #
    # RANGE
    #

    # Gets the locked selection or current selection if el is not given.
    # Otherwise returns the range that represents the el.
    # If a selection does not exist, use #getBlankRange().
    getRange: (el) ->
      if el or !@range
        new Range(@el, el or @win)
      else
        @range

    # Locks the selected range to the given range.
    lockRange: (range) ->
      @range = range

    # Unlocks the selected range.
    unlockRange: ->
      @range = null

    # Get a blank range. This is here in case a selection does not exist.
    # If a selection exists, use #getRange().
    getBlankRange: ->
      new Range(@el)

    # Collapse to the start or end of the current selection.
    # NOTE: This is not directly delegate to the Range object because it is
    # slightly different. This will select the range after collapsing.
    collapse: (start) ->
      range = @getRange()
      range.collapse(start)
      range.select()

    # Moves the selection's boundary to the boundary of the el.
    # NOTE: This is not directly delegate to the Range object because it is
    # slightly different. This will select the range after moving.
    moveBoundary: (boundaries, el) ->
      range = @getRange()
      range.moveBoundary(boundaries, el)
      range.select()

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

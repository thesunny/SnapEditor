# This is the API to the editor.
#
# Properties:
# el: the DOM element that represents the editor
#
# Event Handling Functions:
# on(event, handlerFn): when event is triggred, handlerFn will be called
# off(event, handlerFn): stop listening to the event
# trigger(event, args): event to trigger and an array of args to pass through
#
# Property Functions:
# getContents(): gets the contents of the editor
#
# Editor Functions:
# activate(): activates the editor
# clean(): clean the HTML
#
# Range Functions:
# range([el]): returns the current selection if el is not given, else returns the range that represents the el
# select(el): selects the el
define ["jquery.custom", "core/api/api.exec_command", "core/helpers", "core/events", "core/range"], ($, ExecCommand, Helpers, Events, Range) ->
  class API
    constructor: (@editor) ->
      @el = @editor.$el[0]
      @doc = Helpers.getDocument(@el)
      @win = Helpers.getWindow(@el)
      @config = @editor.config
      @assets = @editor.assets
      @lang = @editor.lang
      @execCommand = new ExecCommand(this)
      @whitelist = @editor.whitelist
      Helpers.delegate(this, "editor",
        "getContents", "setContents", "activate", "tryDeactivate", "deactivate", "save"
      )
      Helpers.delegate(this, "assets", "file", "image", "stylesheet", "template")
      Helpers.delegate(this, "getRange()",
        "isValid", "isCollapsed", "isImageSelected", "isStartOfElement", "isEndOfElement",
        "getParentElement", "getParentElements", "getText",
        "collapse", "unselect", "keepRange", "moveBoundary",
        "insert", "surroundContents", "delete"
      )
      Helpers.delegate(this, "getBlankRange()", "selectNodeContents", "selectEndOfElement")
      Helpers.delegate(this, "execCommand",
        "formatBlock", "formatInline", "indent", "outdent",
        "insertUnorderedList", "insertOrderedList", "insertLink"
      )
      Helpers.delegate(this, "whitelist", "isAllowed", "getReplacement", "getNext")

      # The default is to deactivate immediately. However, to accommodate
      # plugins such as the Save plugin, this can be disabled and handled in a
      # customized way. Use #disableImmediateDeactivate.
      @on("snapeditor.tryDeactivate", @deactivate)

    #
    # DOM SHORTCUTS
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

    #
    # EVENTS
    #

    # Attaches the given event handlers to the given events on all documents on
    # the page.
    #
    # Arguments:
    # * event, event handler
    # * map
    onDocument: ->
      args = arguments
      $(document).on.apply($(document), args)
      $("iframe").each(->
        doc = this.contentWindow.document
        $(doc).on.apply($(doc), args)
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
      $(document).off.apply($(document), args)
      $("iframe").each(->
        doc = this.contentWindow.document
        $(doc).off.apply($(doc), args)
      )

    disableImmediateDeactivate: ->
      @off("snapeditor.tryDeactivate", @deactivate)

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

    # Select the given el. If no el is given, selects the current selection.
    # NOTE: This is not directly delegated to the Range object because it is
    # slightly different. This takes a given element and selects it.
    select: (el) ->
      @getRange(el).select()

    # Add the coordinates relative to the outer window.
    getCoordinates: (range) ->
      range or= @getRange()
      coords = range.getCoordinates()
      coords.outer = $.extend({}, @getCoordinatesRelativeToOuter(coords))
      coords

    #
    # MISCELLANEOUS
    #

    # TODO: This is not part of the API. This should be moved to Helpers when
    # the events infrastructure is added.
    # Given the coordinates relative to an iframe window, translates them to
    # coordinates relative to the outer window.
    getCoordinatesRelativeToOuter: (coords) ->
      return coords if @doc == document
      iframeScroll = $(@win).getScroll()
      iframeCoords = $(@editor.iframe).getCoordinates()
      # Since the coords are relative to the iframe window, we need to
      # translate them so they are relative to the viewport of the iframe and
      # then add on the coordinates of the iframe.
      if typeof coords.top == "undefined"
        outerCoords =
          x: Math.round(coords.x - iframeScroll.x + iframeCoords.left)
          y: Math.round(coords.y - iframeScroll.y + iframeCoords.top)
      else
        outerCoords =
          top: Math.round(coords.top - iframeScroll.y + iframeCoords.top)
          bottom: Math.round(coords.bottom - iframeScroll.y + iframeCoords.top)
          left: Math.round(coords.left - iframeScroll.x + iframeCoords.left)
          right: Math.round(coords.right - iframeScroll.x + iframeCoords.left)
      outerCoords

    # Gets the default block from the whitelist.
    getDefaultBlock: ->
      @whitelist.getDefaults()["*"].getElement(@doc)

    # Calls the cleaner with the given arguments.
    clean: ->
      @trigger("clean", arguments)

  Helpers.include(API, Events)

  return API

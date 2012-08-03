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
# update(): tells the editor to update itself
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
      @execCommand = new ExecCommand(this)
      @whitelist = @editor.whitelist
      Helpers.delegate(this, "editor",
        "getContents", "activate", "deactivate", "update"
      )
      Helpers.delegate(this, "assets", "file", "image", "stylesheet", "template")
      Helpers.delegate(this, "range()",
        "isValid", "isCollapsed", "isImageSelected", "isStartOfElement", "isEndOfElement",
        "getCoordinates", "getParentElement", "getParentElements", "getText",
        "collapse", "unselect", "keepRange",
        "paste", "surroundContents", "delete"
      )
      Helpers.delegate(this, "blankRange()", "selectNodeContents", "selectEndOfElement")
      Helpers.delegate(this, "execCommand",
        "formatBlock", "formatInline", "indent", "outdent",
        "insertUnorderedList", "insertOrderedList", "insertLink"
      )
      Helpers.delegate(this, "whitelist", "allowed", "replacement", "next")

    # Shortcut to the doc's createElement().
    createElement: (name) ->
      @doc.createElement(name)

    # Shortcut to find elements in the doc.
    find: (selector) ->
      matches = $(@doc).find(selector)
      switch matches.length
        when 0 then return null
        when 1 then return matches[0]
        else return matches.toArray()

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

    # Given the coordinates, translates them to mouse coordinates relative to
    # the parent window.
    getMouseCoordinates: (coords) ->
      return coords if @doc == document
      iframeScroll = $(@win).getScroll()
      iframeViewportCoords =
        x: coords.x - iframeScroll.x
        y: coords.y - iframeScroll.y
      iframeCoords = $(@editor.iframe).getCoordinates()
      return {
        x: iframeCoords.left + iframeViewportCoords.x
        y: iframeCoords.top + iframeViewportCoords.y
      }

    # Gets the current selection if el is not given.
    # Otherwise returns the range that represents the el.
    # If a selection does not exist, use #blankRange().
    range: (el) ->
      new Range(@el, el or @win)

    # Get a blank range. This is here in case a selection does not exist.
    # If a selection exists, use #range().
    blankRange: ->
      new Range(@el)

    # Select the given el. If no el is given, selects the current selection.
    # NOTE: This is not directly delegated to the Range object because it is
    # slightly different. This takes a given element and selects it.
    select: (el) ->
      @range(el).select()

    # Gets the default block from the whitelist.
    defaultBlock: ->
      @whitelist.getDefaults()["*"].getElement(@doc)

    # Calls the cleaner with the given arguments.
    clean: ->
      @trigger("clean", arguments)

  Helpers.include(API, Events)

  return API

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
# contents(): gets the contents of the editor
#
# Editor Functions:
# activate(): activates the editor
# update(): tells the editor to update itself
#
# Range Functions:
# range([el]): returns the current selection if el is not given, else returns the range that represents the el
# select(el): selects the el
define ["jquery.custom", "core/helpers", "core/events", "core/range"], ($, Helpers, Events, Range) ->
  class API
    constructor: (@editor) ->
      @el = @editor.$el[0]
      @whitelist = @editor.whitelist
      Helpers.delegate(this, "editor",
        "contents", "activate", "deactivate", "update"
      )
      Helpers.delegate(this, "range()",
        "isCollapsed", "isImageSelected", "getCoordinates", "getParentElement",
        "collapse", "unselect",
        "paste", "surroundContents", "remove"
      )
      Helpers.delegate(this, "blankRange()",
        "selectEndOfElement", "selectEndOfTableCell"
      )
      Helpers.delegate(this, "whitelist",
        "allowed", "replacement", "next"
      )

    # Gets the current selection if el is not given.
    # Otherwise returns the range that represents the el.
    # If a selection does not exist, use #blankRange().
    range: (el) ->
      new Range(@el, el or window)

    # Get a blank range. This is here in case a selection does not exist.
    # If a selection exists, use #range().
    blankRange: ->
      new Range(@el)

    # Select the given el. If no el is given, selects the current selection.
    # NOTE: This is not directly delegated to the Range object because it is
    # slightly different. This takes a given element and selects it.
    select: (el) ->
      @range(el).select()

  Helpers.include(API, Events)

  return API

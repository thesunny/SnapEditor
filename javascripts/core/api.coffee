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
define ["cs!jquery.custom", "cs!core/helpers", "cs!core/events", "cs!core/range"], ($, Helpers, Events, Range) ->
  class API
    constructor: (@editor) ->
      @el = @editor.$el[0]

    # Gets the contents of the editor.
    contents: ->
      @editor.contents()

    # Activates the editor.
    activate: ->
      @editor.activate()

    # Updates the editor.
    update: ->
      @editor.update()

    # Gets the current selection if el is not given.
    # Otherwise returns the range that represents the el.
    range: (el) ->
      new Range(@el, el or window)

    #
    # RANGE SHORTCUTS
    #

    # QUERY RANGE STATE SHORTCUTS

    # Is the selection a caret?
    isCollapsed: ->
      @range().isCollapsed()

    # Gets the coordinates of the current selection.
    getCoordinates: ->
      @range().getCoordinates()

    # Gets the parent element of the current selection.
    getParentElement: (match) ->
      @range().getParentElement(match)

    # MANIPULATE RANGE SHORTCUTS

    # Select the given el.
    select: (el) ->
      @range(el).select()

    # Select the end of the table cell.
    selectEndOfTableCell: (cell) ->
      @range().selectEndOfTableCell(cell)

    # MODIFY RANGE SHORTCUTS

    # Pastes the arg into the current selection.
    paste: (arg) ->
      @range().paste(arg)

    # Surrounds the current selection with the given element.
    surroundContents: (el) ->
      @range().surroundContents(el)

    # Removes the contents of the current selection.
    remove: ->
      @range().remove()

  Helpers.include(API, Events)

  return API

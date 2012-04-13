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
      if typeof el == "undefined"
        new Range(@el, window)
      else
        new Range(@el, el)

    #
    # RANGE SHORTCUTS
    #

    # Select the given el.
    select: (el) ->
      @range(el).select()

    # Gets the coordinates of the current selection.
    getCoordinates: ->
      @range().getCoordinates()

  Helpers.include(API, Events)

  return API

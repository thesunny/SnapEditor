define ["jquery.custom"], ($) ->
  return {
    # Get the coordinates of the range.
    #
    # NOTE:
    # IE has two types of ranges: textRange and controlRange.
    # In order to calculate the coordinates, we need to handle each type.
    #
    # IE's textRange has getBoundingClientRect() which returns a ClientRect.
    # This ClientRect has information about the coordinates of the currently
    # selected range. Unfortunately, IE8 breaks this and returns very odd
    # coordinates and is not reliable. Instead, we revert back to inserting
    # spans and getting the coordinates.
    #
    # IE's controlRange contains a list of items. A controlRange is usually
    # created when an image is selected. The first item in the list will be
    # the image that is selected. We grab that item and find its coordinates.
    getCoordinates: ->
      if @range.getBoundingClientRect
        if @isCollapsed()
          # If it's collapsed, we can optimize by only getting the start.
          coords = @getEdgeCoordinates(true)
        else
          startCoords = @getEdgeCoordinates(true)
          endCoords = @getEdgeCoordinates(false)
          coords =
            top: startCoords.top,
            bottom: endCoords.bottom
      else
        coords = $(@range.item(0)).getCoordinates()
      coords

    # Returns the coordinates of the start of the range if true. Otherwise,
    # returns the end.
    #
    # NOTE: This uses bookmarks beause it preserves the direction of the
    # selection.
    getEdgeCoordinates: (start) ->
      bookmark = @range.getBookmark()
      @range.collapse(start)
      # TODO: Remove this comment once it is confirmed that el.focus() is not
      # called.
      # Don't use pasteNode() here. pasteNode() calls el.focus()
      # which will make IE scroll the window so that the range is
      # on the bottom of the screen. Hence, we use pasteHTML.
      @pasteHTML('<span id="CURSORPOS"></span>')
      span = $('#CURSORPOS')
      coords = span.getCoordinates()
      span.remove()
      @range.moveToBookmark(bookmark)
      coords
  }

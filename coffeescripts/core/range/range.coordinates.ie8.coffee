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
    #
    # NOTE: Unfortunately, inserting a span and removing it causes IE8 to
    # reselect the range. Whenever IE8 selects a range, the focus is moved to
    # wherever the cursor is, even if it is supposed to be off the screen.
    # This causes problems when scrolling where the page always bounces to
    # where the cursor is. To avoid this problem, we use execCommand() to
    # create a link and find it. We then get the coordinates from the link and
    # remove the link using execCommand("undo"). This does not reselect the
    # range and IE8 no longer bounces.
    getEdgeCoordinates: (start) ->
      bookmark = @range.getBookmark()
      @range.collapse(start)
      randomHref = "http://snapeditor.com/#{Math.floor(Math.random() * 99999)}"
      # It is required that we use @range.execCommand() instead of
      # @doc.execCommand() or the undo will not work.
      @range.execCommand("createLink", false, randomHref)
      $a = $(@find("a[href=\"#{randomHref}\"]"))
      coords = $a.getCoordinates()
      # It is required that we use @doc.execCommand() here because
      # @range.execCommand() does not undo the createLink.
      @doc.execCommand("undo")
      @range.moveToBookmark(bookmark)
      coords
  }

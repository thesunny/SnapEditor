# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
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
    # selected range. Unfortunately, IE8 breaks this in certain cases and
    # returns very odd coordinates and is not reliable. The odd cases return 0
    # for everything:
    # 1. collapsed at the end of an element
    # 2. collapsed right before an image
    # Note that if you have a selection, then it's okay if the selection
    # starts/ends on an odd case.
    # We capture the odd cases by seeing if the top and bottom are equal.
    # We used to do the span insertion method mentioned below, but found out
    # that if you are at the end of the line, because the range is collapsed,
    # it gives coordinates of the line below. I'm guessing it's because being
    # at the end of a line and beginning of a line is the "same" thing.
    # Hence, instead, we now check to see if the range is collapsed. If it is,
    # we make it uncollapsed by selecting the previous character and get the
    # last client rectangle. We use the previous character instead of the next
    # or else we run into the same problem as selecting forward means we're on
    # the next line. We only use the span insertion method if the last client
    # rectangle doesn't exist.
    #
    # The span insertion method:
    # We insert a span, grab the span's coordinates, and then remove the span.
    # We're lucky because the span method makes the page jump in all cases
    # except for when it's at the end of an element. Perfect for case #1.
    # Unfortunately, this still makes case #2 jump. However, the coordinates
    # are correct now. Inserting spans for case #2 also introduces a second
    # problem where we can't use the keyboard down arrow to cursor past an
    # image.
    # The jumping for case #2 is okay because we don't get coordinates unless
    # the cursor is already in view. This may change later and we will have to
    # figure this out.
    # As for the cursoring past an image, we are okay with leaving that for
    # now.
    #
    # IE's controlRange contains a list of items. A controlRange is usually
    # created when an image is selected. The first item in the list will be
    # the image that is selected. We grab that item and find its coordinates.
    #
    # The left and right coordinates returned are not always the left and
    # right of the bounding rectangle. In the case where spans must be
    # inserted, the left is the left of the start span and the right is the
    # right of the end span.
    getCoordinates: ->
      if @range.getBoundingClientRect
        clientRect = @range.getBoundingClientRect()
        if clientRect.top == clientRect.bottom
          if @isCollapsed()
            body = @find("body")[0]
            measureRange = @range.duplicate()
            measureRange.moveStart("character", -1)
            clientRects = measureRange.getClientRects()
            clientRect = clientRects[clientRects.length - 1]
            if clientRect
              coords = @getCoordinatesFromClientRect(clientRect)
            else
              coords = @getCoordinatesFromEdges()
          else
            coords = @getCoordinatesFromEdges()
        else
          coords = @getCoordinatesFromClientRect(clientRect)
      else
        coords = $(@range.item(0)).getCoordinates()
      coords

    # The clientRect is relative to the viewport. We want the coordinates
    # relative to the document.
    getCoordinatesFromClientRect: (clientRect) ->
      windowScroll = $(@win).getScroll()
      coords =
        top: clientRect.top + windowScroll.y
        bottom: clientRect.bottom + windowScroll.y
        left: clientRect.left + windowScroll.x
        right: clientRect.right + windowScroll.x

    # Find the start and end edges and combine them to find the coordinates.
    getCoordinatesFromEdges: ->
      startCoords = @getEdgeCoordinates(true)
      endCoords = @getEdgeCoordinates(false)
      coords =
        top: startCoords.top
        bottom: endCoords.bottom
        left: startCoords.left
        right: endCoords.right

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
    # where the cursor is. There does not seem to be a workaround. Things
    # tried:
    # - unselecting the range (but you need to reselect anyways)
    # - normalize after removing
    # - @range.execCommand("createLink") then @doc.execCommand("undo")
    #
    # NOTE: The only time it doesn't make the page jump is when we're
    # collapsed at the end of an element. We don't even need to be at the end
    # of a top level block. The end of any element will do.
    getEdgeCoordinates: (start) ->
      bookmark = @range.getBookmark()
      @range.collapse(start)
      @range.pasteHTML('<span id="CURSORPOS"></span>')
      $span = @find("#CURSORPOS")
      coords = $span.getCoordinates()
      $parent = $span.parent()
      $span.remove()
      @range.moveToBookmark(bookmark)
      coords
  }

# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  return {
    # Gecko's range has #getBoundingClientRect() which returns a ClientRect.
    # This is similar to IE's range except it doesn't return the correct
    # coordinates when the range is collapsed. Instead it returns all zeros.
    # There are three workarounds.
    # 1. Use the more basic function #getClientRects() and use the first
    #    rectangle. This gives the correct coordinates. However, there are
    #    certain cases where this doesn't work. For instance, when the cursor
    #    is beside an <img> or <hr>.
    # 2. We observe that solution (1) doesn't work because it is collapsed.
    #    Hence, we create a temporary range that starts at the same place and
    #    make it select to the end of the body. We then take the first
    #    clientRect. However, the right side is not correct, but it is okay
    #    because the range is collapsed. We just replace the right side with
    #    the left coordinate. There is one problem. When the cursor is
    #    collapsed and at the end and there are no other elements after it
    #    (usually at the end of an iframe of the form SnapEditor), the
    #    temporary range remains collapsed instead of a selection. This
    #    returns zero client rectangles.
    # 3. The last resort is to insert a <span> and measure its coordinates.
    #    However, this solution has its drawbacks because we now have to deal
    #    with cleaning up after ourselves.
    # Solution (2) was chosen overall because it solves all of our problems
    # except for when it doesn't return a client rectangle. Only in this last
    # case do we use solution (3).
    getCoordinates: ->
      if @isCollapsed()
        body = @find("body")[0]
        measureRange = @constructor.getBlankRange()
        measureRange.setStart(@range.startContainer, @range.startOffset)
        measureRange.setEnd(body, body.childNodes.length)
        clientRect = measureRange.getClientRects()[0]
        if clientRect
          coords = @getCoordinatesFromClientRect(clientRect)
        else
          coords = @getCoordinatesFromSpan()
        coords.right = coords.left
      else
        coords = @getCoordinatesFromClientRect(@range.getBoundingClientRect())
      coords

    # The clientRect is relative to the viewport. We want the coordinates
    # relative to the document.
    getCoordinatesFromClientRect: (clientRect) ->
      windowScroll = $(@win).getScroll()
      # Round the numbers because Gecko returns decimal pixels.
      coords =
        top: Math.round(clientRect.top + windowScroll.y)
        bottom: Math.round(clientRect.bottom + windowScroll.y)
        left: Math.round(clientRect.left + windowScroll.x)
        right: Math.round(clientRect.right + windowScroll.x)

    getCoordinatesFromSpan: ->
      # Without content in the span, Gecko calculates the height of the span
      # as 0. Hence, the top and bottom coordinates are the same. In order to
      # get the real top and bottom, we insert a zero-width no-break space.
      @insertNode(@createElement("span").attr("id", "CURSORPOS").html(Helpers.zeroWidthNoBreakSpace)[0])
      $span = @find("#CURSORPOS")
      coords = $span.getCoordinates()
      $span.remove()
      coords
  }

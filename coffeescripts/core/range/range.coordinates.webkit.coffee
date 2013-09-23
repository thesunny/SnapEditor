# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  return {
    # Webkit's range has #getBoundingClientRect() which returns a ClientRect.
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
    #    the left coordinate. Also, for some reason, the top measurement is -1
    #    off the real coordinate. Hence, we add back the missing 1 px.
    # 3. The last resort is to insert a <span> and measure its coordinates.
    #    However, this solution has its drawbacks because we now have to deal
    #    with cleaning up after ourselves.
    # Solution (2) was chosen overall because it solves all of our problems.
    # We don't even need to bother with solution (3).
    getCoordinates: ->
      if @isCollapsed()
        body = @find("body")[0]
        measureRange = @constructor.getBlankRange()
        measureRange.setStart(@range.startContainer, @range.startOffset)
        measureRange.setEnd(body, body.childNodes.length)
        coords = @getCoordinatesFromClientRect(measureRange.getClientRects()[0])
        coords.top += 1
        coords.right = coords.left
      else
        coords = @getCoordinatesFromClientRect(@range.getBoundingClientRect())
      coords

    # The clientRect is relative to the viewport. We want the coordinates
    # relative to the document.
    getCoordinatesFromClientRect: (clientRect) ->
      windowScroll = $(@win).getScroll()
      # Round the numbers because Webkit returns decimal pixels.
      coords =
        top: Math.round(clientRect.top + windowScroll.y)
        bottom: Math.round(clientRect.bottom + windowScroll.y)
        left: Math.round(clientRect.left + windowScroll.x)
        right: Math.round(clientRect.right + windowScroll.x)
  }

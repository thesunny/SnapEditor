# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom"], ($) ->
  return {
    # IE has two types of ranges: textRange and controlRange.
    # In order to calculate the coordinates, we need to handle each type.
    #
    # IE's textRange has getBoundingClientRect() which returns a ClientRect.
    # this ClientRect has information about the coordinates of the currently
    # selected range. However, it returns the coordinates relative to the
    # viewport. Hence, we need to account for scrolling.
    #
    # IE's controlRange contains a list of items. A controlRange is usually
    # created when an image is selected. The first item in the list will be
    # the image that is selected. We grab that item and find its coordinates.
    getCoordinates: ->
      if @range.getBoundingClientRect
        clientRect = @range.getBoundingClientRect()
        windowScroll = $(@win).getScroll()
        coords =
          top: clientRect.top + windowScroll.y
          bottom: clientRect.bottom + windowScroll.y
          left: clientRect.left + windowScroll.x
          right: clientRect.right + windowScroll.x
      else
        coords = $(@range.item(0)).getCoordinates()
      coords
  }

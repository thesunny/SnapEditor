# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers", "core/toolbar/toolbar.menu.submenu"], ($, Helpers, Submenu) ->
  class Flyout extends Submenu
    getSubmenuClass: ->
      Flyout

    getStyles: ->
      # The entire idea here is to try to show the entire flyout to the right,
      # then left, while keeping it vertically in view.
      relCoords = @$relEl.getCoordinates(true)
      elSize = @$el.getSize(true, true)
      windowSize = $(window).getSize()
      windowScroll = $(window).getScroll()
      windowBoundary = Helpers.getWindowBoundary()

      styles = {}
      # Fit horizontally first.
      if relCoords.right + elSize.x <= windowBoundary.right
        # Fits to the right.
        styles.left = relCoords.right
      else
        # Doesn't fit to the right.
        styles.left = relCoords.left - elSize.x
      # Then fit vertically.
      if relCoords.top + elSize.y <= windowBoundary.bottom
        # Fits below.
        styles.top = relCoords.top
      else
        # Doesn't fit below.
        if relCoords.bottom - elSize.y >= windowBoundary.top
          # Fits above.
          styles.top = relCoords.bottom - elSize.y
        else
          # Doesn't fit above.
          styles.top = windowBoundary.top

      styles

# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers", "core/toolbar/toolbar.menu.submenu", "core/toolbar/toolbar.menu.flyout"], ($, Helpers, Submenu, Flyout) ->
  class Dropdown extends Submenu
    getSubmenuClass: ->
      Flyout

    getStyles: ->
      # The entire idea here is that we don't want to cover the button. Hence,
      # we try to position below, above, right then left.
      relCoords = @$relEl.getCoordinates(true)
      elSize = @$el.getSize(true, true)
      windowBoundary = Helpers.getWindowBoundary()

      fitsVertically = true
      styles = {}
      # Fit vertically first.
      if relCoords.bottom + elSize.y <= windowBoundary.bottom
        # Fits below.
        styles.top = relCoords.bottom
      else
        # Doesn't fit below.
        if relCoords.top - elSize.y >= windowBoundary.top
          # Fits above.
          styles.top = relCoords.top - elSize.y
        else
          # Doesn't fit above.
          styles.top = windowBoundary.top
          fitsVertically = false
      # Then fit horizontally.
      if fitsVertically
        # If the dropdown fits vertically, align the left side of the submenu
        # with the left side of the button, or align the right side of the
        # submenu with the right side of the window.
        left = relCoords.left
        right = windowBoundary.right
      else
        # If the dropdown doesn't fit vertically, align the left side of the
        # submenu with the right side of the button, or align the right side
        # of the submenu with the left side of the button.
        left = relCoords.right
        right = relCoords.left

      if left + elSize.x <= windowBoundary.right
        # Fits to the right.
        styles.left = left
      else
        # Doesn't fit to the right.
        # We ignore it if it doesn't fit to the left because that's just
        # ridiculous.
        styles.left = right - elSize.x

      styles

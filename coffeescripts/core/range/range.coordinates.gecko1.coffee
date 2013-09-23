# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  return {
    # Gecko unfortunately does not provide getBoundingClientRect() until Gecko
    # 2.0 (Firefox 4+). In order to figure out the coordinates, we insert
    # spans before or after the range, get the coordinates, then destroy the
    # spans. We then reselect the range.
    #
    # However, there was a big problem with reselecting the range. In W3C
    # browsers, when reselecting the range, it forgets which way the range was
    # selected (forwards/backwards). Hence, it always selects the range going
    # forwards. This broke the ability to extend a selection backwards. It
    # would always clear the previous selection before extending backwards.
    # Note that extending the selection forwards was fine.
    #
    # This was solved by figuring out the original direction. If it was
    # forwards, nothing needed to be done. If it was backwards, we needed to
    # collapse the selection to the end, then extend the selection back to the
    # start to correct the direction.
    #
    # Note that this does not find the full coordinates for the range as in
    # the other browsers. If we insert spans both before and after the range
    # to find the top and bottom, if more than one page has been selected, the
    # window will jump first to the top, then to the bottom of the selection.
    # this happens because we must select the range to insert the spans. Instead
    # of having the screen jump, we only return either the top or bottom
    # coordinates. If the selection is moving forwards, we only return the
    # bottom coordinate reliably. If the selection is moving backwards, we only
    # return the top coordinate reliably.
    #
    # When the selection is an image, the coordinates are not exact because a
    # span is used to calculate the coordinates. The span will not have the
    # same height as the image and so the top and bottom coordinates may be
    # off.
    #
    # The left and right coordinates do not represent the bounding rectangle.
    # It is the left and right coordinates of the inserted span.
    getCoordinates: ->
      backwards = @isMovingBackwards()
      savedRange = @range.cloneRange()

      # Firefox has some quirkiness.
      #
      # When selecting backwards, we need to use document.execCommand() here
      # instead of #insertNode() which uses range.insertNode(). When using
      # range.insertNode(), we cannot reselect the savedRange. It seems like
      # range.insertNode() somehow destroys the ordering of the containers and
      # offsets. this makes the savedRange invalid. If we use
      # document.execCommand(), all seems to be fine.
      #
      # When selecting forwards, the opposite is true. Here,
      # document.execCommand() makes the savedRange invalid. #insertNode() does
      # not have this effect and everything is ok.
      @collapse(backwards)
      if backwards
        # #collapse() only modifies the range, not the selection. We use
        # document.execCommand() later which acts on the selection, not the
        # range. Hence, we need to make sure we call #select() after collapsing
        # to ensure the selection is also modified.
        @select()
        # Without content in the span, Firefox calculates the height of the span
        # as 0. Hence, the top and bottom coordinates are the same. In order to
        # get the real top and bottom, we insert a zero width no-break space.
        @document.execCommand('inserthtml', false, "<span id=\"CURSORPOS\">#{Helpers.zeroWidthNoBreakSpace}</span>")
      else
        # Without content in the span, Firefox calculates the height of the span
        # as 0. Hence, the top and bottom coordinates are the same. In order to
        # get the real top and bottom, we insert a zero width no-break space.
        @insertNode($("<span id=\"CURSORPOS\">#{Helpers.zeroWidthNoBreakSpace}</span>")[0])
      $span = $('#CURSORPOS')
      coords = $span.getCoordinates()
      $span.remove()

      # Reselect the saved range.
      @select(savedRange)

      # If we were originally moving backwards, we need to make sure the
      # direction of the reselected range is also backwards.
      if backwards
        selection = @win.getSelection()
        selection.collapseToEnd()
        selection.extend(@range.startContainer, @range.endContainer)

      coords

    # Returns true if the selection was made moving backwards. False otherwise.
    isMovingBackwards: ->
      # If the anchor of the selection does not match the start of the range,
      # then the selection was made moving backwards.
      selection = @win.getSelection()
      selection.anchorNode != @range.startContainer or selection.anchorOffset != @range.startOffset
   }

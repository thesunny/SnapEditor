define ["jquery.custom"], ($) ->
  return {
    # Webkit's range has #getBoundingClientRect() which returns a ClientRect.
    # This is similar to IE's range except it doesn't return the correct
    # values when the range is collapsed. When the range is collapsed,
    # #getBoundingClientRect() returns null. Until this gets fixed, if the
    # range is collapsed, we insert a span, get the span's coordinates, then
    # destroy it.
    getCoordinates: ->
      if @isCollapsed()
        # Without content in the span, Webkit calculates the height
        # of the span as 0. Hence, the top and bottom coordinates are
        # the same. In order to get the real top and bottom, we insert
        # a zero width no-break space.
        @pasteNode($('<span id="CURSORPOS">&#65279</span>')[0])
        span = $('#CURSORPOS')
        coords = span.getCoordinates()
        span.remove()
      else
        # This part is the same as IE's textRange.
        clientRect = @range.getBoundingClientRect()
        windowScroll = $(@win).getScroll()
        coords =
          top: clientRect.top + windowScroll.y,
          bottom: clientRect.bottom + windowScroll.y,
          left: clientRect.left + windowScroll.x,
          right: clientRect.right + windowScroll.x
      coords
  }

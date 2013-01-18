define ["jquery.custom", "core/helpers"], ($, Helpers) ->
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
        @insert($(@createElement("span")).attr("id", "CURSORPOS").html(Helpers.zeroWidthNoBreakSpace)[0])
        $span = @find('#CURSORPOS')
        coords = $span.getCoordinates()
        # NOTE: When the spans are added, they split up textnodes. This causes
        # problems in Webkit. For example, when the range is at the beginning
        # of a list item and the textnodes were not merged back together,
        # calling indent/outdent through document.execCommand() would exhibit
        # crazy behaviour. Hence, we call normalize() on the parents to clean
        # up the textnodes.
        $span.parent()[0].normalize()
        $span.remove()
        # NOTE: In Safari only (not in Chrome), the selection gets lost after
        # the insert. Hence we need to reselec it. There is no harm in leaving
        # it in for Chrome.
        @select()
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

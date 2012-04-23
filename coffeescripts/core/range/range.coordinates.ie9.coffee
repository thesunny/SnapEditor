define ["jquery.custom"], ($) ->
  return {
    # IE9 has three types of ranges: textRange, controlRange, and W3C range.
    # Since IE9 is W3C compatible, we use the W3C range.
    #
    # IE9 W3C range has #getBoundingClientRect() which gives the coordinates of
    # hte range relative to the viewport. Hence, we need to account for
    # scrolling.
    #
    # Unfortunately, #getBoundingClientRect() returns 0 for everything when an
    # image is selected. We handle images by getting the image directly and
    # using jQuery to find the coordinates of the image.
    getCoordinates: ->
      if @isImageSelected()
        # The range's startContainer and startOffset is set to the image.
        coords = $(@range.startContainer.childNodes[@range.startOffset]).getCoordinates()
      else
        clientRect = @range.getBoundingClientRect()
        windowScroll = $(window).getScroll()
        coords =
          top: clientRect.top + windowScroll.y,
          bottom: clientRect.bottom + windowScroll.y,
          left: clientRect.left + windowScroll.x,
          right: clientRect.right + windowScroll.x
      coords
  }

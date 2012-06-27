define ["jquery.custom", "core/helpers"], ($, Helpers) ->
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
        img = @range.startContainer.childNodes[@range.startOffset]
        # In IE9, if the image is selected, but you click on the perimeter of
        # the image, the startContainer is a textnode before the image and the
        # endContainer is a textnode after the image. For instance, if you
        # click on the corner square box used for resizing. Hence, we check for
        # this and use the startContainer's nextSibling to find the image.
        if typeof img == "undefined" or !Helpers.isElement(img) or $(img).tagName() != "img"
          img = @range.startContainer.nextSibling
        coords = $(img).getCoordinates()
      else
        if @isCollapsed()
          @paste($('<span id="CURSORPOS"/>')[0])
          span = $('#CURSORPOS')
          coords = span.getCoordinates()
          span.remove()
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

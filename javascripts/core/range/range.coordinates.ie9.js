
define(["jquery.custom"], function($) {
  return {
    getCoordinates: function() {
      var clientRect, coords, windowScroll;
      if (this.isImageSelected()) {
        coords = $(this.range.startContainer.childNodes[this.range.startOffset]).getCoordinates();
      } else {
        clientRect = this.range.getBoundingClientRect();
        windowScroll = $(window).getScroll();
        coords = {
          top: clientRect.top + windowScroll.y,
          bottom: clientRect.bottom + windowScroll.y,
          left: clientRect.left + windowScroll.x,
          right: clientRect.right + windowScroll.x
        };
      }
      return coords;
    }
  };
});

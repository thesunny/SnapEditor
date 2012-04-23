
define(["jquery.custom"], function($) {
  return {
    getCoordinates: function() {
      var clientRect, coords, windowScroll;
      if (this.range.getBoundingClientRect) {
        clientRect = this.range.getBoundingClientRect();
        windowScroll = $(window).getScroll();
        coords = {
          top: clientRect.top + windowScroll.y,
          bottom: clientRect.bottom + windowScroll.y,
          left: clientRect.left + windowScroll.x,
          right: clientRect.right + windowScroll.x
        };
      } else {
        coords = $(this.range.item(0)).getCoordinates();
      }
      return coords;
    }
  };
});

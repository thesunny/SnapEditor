
define(["jquery.custom"], function($) {
  return {
    getCoordinates: function() {
      var clientRect, coords, span, windowScroll;
      if (this.isCollapsed()) {
        this.pasteNode($('<span id="CURSORPOS">&#65279</span>')[0]);
        span = $('#CURSORPOS');
        coords = span.getCoordinates();
        span.remove();
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

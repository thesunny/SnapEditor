
define(["jquery.custom"], function($) {
  return {
    getCoordinates: function() {
      var coords, endCoords, startCoords;
      if (this.range.getBoundingClientRect) {
        if (this.isCollapsed()) {
          coords = this.getEdgeCoordinates(true);
        } else {
          startCoords = this.getEdgeCoordinates(true);
          endCoords = this.getEdgeCoordinates(false);
          coords = {
            top: startCoords.top,
            bottom: endCoords.bottom
          };
        }
      } else {
        coords = $(this.range.item(0)).getCoordinates();
      }
      return coords;
    },
    getEdgeCoordinates: function(start) {
      var bookmark, coords, span;
      bookmark = this.range.getBookmark();
      this.range.collapse(start);
      this.pasteHTML('<span id="CURSORPOS"></span>');
      span = $('#CURSORPOS');
      coords = span.getCoordinates();
      span.remove();
      this.range.moveToBookmark(bookmark);
      return coords;
    }
  };
});

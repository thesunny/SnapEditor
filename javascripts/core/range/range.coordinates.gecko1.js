
define(["jquery.custom"], function($) {
  return {
    getCoordinates: function() {
      var $span, backwards, coords, savedRange, selection;
      backwards = this.isMovingBackwards();
      savedRange = this.range.cloneRange();
      this.collapse(backwards);
      if (backwards) {
        this.select();
        document.execCommand('inserthtml', false, '<span id="CURSORPOS">&#65279</span>');
      } else {
        this.pasteNode($('<span id="CURSORPOS">&#65279</span>')[0]);
      }
      $span = $('#CURSORPOS');
      coords = $span.getCoordinates();
      $span.remove();
      this.select(savedRange);
      if (backwards) {
        selection = window.getSelection();
        selection.collapseToEnd();
        selection.extend(this.range.startContainer, this.range.endContainer);
      }
      return coords;
    },
    isMovingBackwards: function() {
      var selection;
      selection = window.getSelection();
      return selection.anchorNode !== this.range.startContainer || selection.anchorOffset !== this.range.startOffset;
    }
  };
});


define([], function() {
  return {
    start: function() {
      this.api.el.contentEditable = true;
      return document.execCommand("enableObjectResizing", false, false);
    }
  };
});

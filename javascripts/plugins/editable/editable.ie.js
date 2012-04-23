
define(["core/range"], function(Range) {
  return {
    start: function() {
      this.api.el.contentEditable = true;
      return this.api.el.attachEvent("onresizestart", this.preventResize);
    },
    deactivateBrowser: function() {
      return this.api.el.detachEvent("onresizestart", this.preventResize);
    },
    preventResize: function(e) {
      return e.returnValue = false;
    }
  };
});


define(["jquery.custom"], function($) {
  return {
    addActivateEvents: function() {
      var _this = this;
      return $(this.api.el).one("mouseup", function() {
        return _this.onmouseup.apply(_this, arguments);
      });
    },
    onmouseup: function(e) {
      var isImage, range, target;
      target = e.target;
      if (!this.isLink(target)) {
        isImage = $(target).tagName() === "img";
        if (!isImage) range = this.api.range();
        this.click();
        if (isImage) {
          this.api.select(target);
        } else {
          range.select();
        }
        return this.activate();
      }
    }
  };
});

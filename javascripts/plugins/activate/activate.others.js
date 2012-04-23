
define(["jquery.custom"], function($) {
  return {
    addActivateEvents: function() {
      var _this = this;
      $(this.api.el).one("mousedown", function() {
        return _this.onmousedown.apply(_this, arguments);
      });
      return $(this.api.el).one("mouseup", function() {
        return _this.onmouseup.apply(_this, arguments);
      });
    },
    onmousedown: function(e) {
      if (!this.isLink(e.target)) return this.click();
    },
    onmouseup: function(e) {
      var target;
      target = e.target;
      if (!this.isLink(target)) {
        if ($(target).tagName() === 'img') this.api.select(target);
        return this.activate();
      }
    }
  };
});

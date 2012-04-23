var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(["jquery.custom"], function($) {
  var DataActionHandler;
  DataActionHandler = (function() {

    function DataActionHandler(el, api, namespace) {
      this.api = api;
      this.namespace = namespace;
      this.change = __bind(this.change, this);
      this.click = __bind(this.click, this);
      this.setClick = __bind(this.setClick, this);
      this.$el = $(el);
      this.$el.children("select[data-action]").on("change", this.change);
      this.$el.on("mousedown", this.setClick);
      this.$el.on("mouseup", this.click);
      this.$el.on("keypress", this.change);
    }

    DataActionHandler.prototype.setClick = function(e) {
      return this.isClick = true;
    };

    DataActionHandler.prototype.click = function(e) {
      var $button, target;
      if (this.isClick) {
        target = e.target;
        $button = $(target).closest("[data-action]:not(select)");
        if ($button.length > 0) {
          e.preventDefault();
          e.stopPropagation();
          this.api.trigger("" + ($button.attr("data-action")) + "." + this.namespace, target);
        }
      }
      this.isClick = false;
      return true;
    };

    DataActionHandler.prototype.change = function(e) {
      var $target;
      $target = $(e.target);
      if ($target.attr("data-action")) {
        return this.api.trigger("" + ($target.attr("data-action")) + "." + this.namespace, $target.val());
      }
    };

    return DataActionHandler;

  })();
  return DataActionHandler;
});

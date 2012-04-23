var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(["jquery.custom"], function($) {
  var Autoscroll;
  Autoscroll = (function() {

    function Autoscroll() {
      this.autoscroll = __bind(this.autoscroll, this);
      this.stop = __bind(this.stop, this);
      this.start = __bind(this.start, this);
    }

    Autoscroll.prototype.options = {
      topMargin: 50,
      bottomMargin: 50
    };

    Autoscroll.prototype.register = function(api) {
      this.api = api;
      this.api.on("activate.editor", this.start);
      return this.api.on("deactivate.editor", this.stop);
    };

    Autoscroll.prototype.start = function() {
      return $(this.api.el).on("keyup", this.autoscroll);
    };

    Autoscroll.prototype.stop = function() {
      return $(this.api.el).off("keyup", this.autoscroll);
    };

    Autoscroll.prototype.autoscroll = function() {
      var bottomLine, cursor, scroll, topLine, winSize;
      cursor = this.api.getCoordinates();
      scroll = $(window).getScroll();
      winSize = $(window).getSize();
      topLine = cursor.top - this.options.topMargin;
      bottomLine = cursor.bottom + this.options.bottomMargin - winSize.y;
      if (topLine < scroll.y) {
        return window.scrollTo(scroll.x, topLine);
      } else if (bottomLine > scroll.y) {
        return window.scrollTo(scroll.x, bottomLine);
      }
    };

    return Autoscroll;

  })();
  return Autoscroll;
});

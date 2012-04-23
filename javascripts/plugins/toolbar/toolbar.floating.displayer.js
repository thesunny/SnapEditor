var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(["jquery.custom", "plugins/toolbar/toolbar.floating.displayer.styles"], function($, Styles) {
  var Displayer;
  Displayer = (function() {

    function Displayer(toolbar, el, api) {
      this.api = api;
      this.updateAndCheckCursor = __bind(this.updateAndCheckCursor, this);
      this.update = __bind(this.update, this);
      this.hide = __bind(this.hide, this);
      this.show = __bind(this.show, this);
      this.$toolbar = $(toolbar);
      this.$el = $(el);
      this.shown = false;
      this.positionedAtTop = true;
      this.$toolbar.hide().appendTo("body");
    }

    Displayer.prototype.getHeight = function() {
      return parseInt(this.$toolbar.css('height'));
    };

    Displayer.prototype.setup = function() {
      this.styles = new Styles(this.$el, this.$toolbar);
      $(window).on("scroll resize", this.update);
      return this.$el.on("mouseup keyup", this.updateAndCheckCursor);
    };

    Displayer.prototype.teardown = function() {
      $(window).off("scroll resize", this.update);
      return this.$el.off("mouseup keyup", this.updateAndCheckCursor);
    };

    Displayer.prototype.show = function() {
      if (!this.shown) {
        this.setup();
        this.$toolbar.show();
        this.shown = true;
        return this.updateAndCheckCursor();
      }
    };

    Displayer.prototype.hide = function() {
      if (this.shown) {
        this.$toolbar.hide();
        this.shown = false;
        return this.teardown();
      }
    };

    Displayer.prototype.update = function(checkCursor) {
      if (this.shown) {
        if (this.positionedAtTop) {
          this.positionAtTop();
          if (checkCursor && this.isCursorInOverlapSpace()) {
            return this.moveToBottom();
          }
        } else {
          this.positionAtBottom();
          if (checkCursor && !this.isCursorInOverlapSpace()) {
            return this.moveToTop();
          }
        }
      }
    };

    Displayer.prototype.updateAndCheckCursor = function() {
      return this.update(true);
    };

    Displayer.prototype.elCoords = function() {
      return this.$el.getCoordinates();
    };

    Displayer.prototype.toolbarSize = function() {
      return this.$toolbar.getSize();
    };

    Displayer.prototype.cursorPosition = function() {
      return this.api.getCoordinates().top;
    };

    Displayer.prototype.positionAtTop = function() {
      this.positionedAtTop = true;
      return this.$toolbar.css(this.styles.top());
    };

    Displayer.prototype.positionAtBottom = function() {
      this.positionedAtTop = false;
      return this.$toolbar.css(this.styles.bottom());
    };

    Displayer.prototype.moveToTop = function() {
      this.positionedAtTop = true;
      return this.$toolbar.animate(this.styles.top(), {
        duration: 'fast'
      });
    };

    Displayer.prototype.moveToBottom = function() {
      this.positionedAtTop = false;
      return this.$toolbar.animate(this.styles.bottom(), {
        duration: 'fast'
      });
    };

    Displayer.prototype.overlapSpaceFromElTop = function() {
      var elCoords, overlap;
      elCoords = this.elCoords();
      overlap = this.toolbarSize().y - elCoords.top;
      if (overlap > 0) {
        return overlap;
      } else {
        return 0;
      }
    };

    Displayer.prototype.isCursorInOverlapSpace = function() {
      var cursorPositionInEl;
      cursorPositionInEl = this.cursorPosition() - this.elCoords().top;
      return cursorPositionInEl < this.overlapSpaceFromElTop();
    };

    return Displayer;

  })();
  return Displayer;
});

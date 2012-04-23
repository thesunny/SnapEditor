
define(["jquery.custom", "core/browser"], function($, Browser) {
  var Styles;
  Styles = (function() {

    function Styles(el, floater) {
      this.$el = $(el);
      this.$floater = $(floater);
    }

    Styles.prototype.top = function() {
      var styles;
      if (this.doesFloaterFit("top")) {
        styles = {
          position: "absolute",
          top: this.elCoords().top - this.floaterSize().y
        };
      } else {
        styles = this.topFixed();
      }
      return $.extend(styles, this.x());
    };

    Styles.prototype.bottom = function() {
      var styles;
      if (this.doesFloaterFit("bottom")) {
        styles = {
          position: "absolute",
          top: this.elCoords().bottom
        };
      } else {
        styles = this.bottomFixed();
      }
      return $.extend(styles, this.x());
    };

    Styles.prototype.elCoords = function() {
      return this.$el.getCoordinates();
    };

    Styles.prototype.floaterSize = function() {
      return this.$floater.getSize();
    };

    Styles.prototype.x = function() {
      var floaterLeft, floaterSize, windowSize;
      floaterSize = this.floaterSize();
      windowSize = $(window).getSize();
      floaterLeft = this.elCoords().left;
      if (floaterLeft < 0) {
        floaterLeft = 0;
      } else if (floaterLeft + floaterSize.x > windowSize.x) {
        floaterLeft = windowSize.x - floaterSize.x;
      }
      return {
        left: floaterLeft
      };
    };

    Styles.prototype.spaceBetweenElAndWindow = function(where) {
      var elCoords, space, windowScroll;
      elCoords = this.elCoords();
      windowScroll = $(window).getScroll();
      space = 0;
      if (where === "top") {
        space = elCoords.top - windowScroll.y;
      } else {
        space = windowScroll.y + $(window).getSize().y - elCoords.bottom;
      }
      return space;
    };

    Styles.prototype.doesFloaterFit = function(where) {
      return this.spaceBetweenElAndWindow(where) >= this.floaterSize().y;
    };

    Styles.prototype.topFixed = function() {
      if (Browser.isIE) {
        return {
          position: "absolute",
          top: $(window).getScroll().y
        };
      } else {
        return {
          position: "fixed",
          top: 0
        };
      }
    };

    Styles.prototype.bottomFixed = function() {
      if (Browser.isIE) {
        return {
          position: "absolute",
          top: $(window).getScroll().y + $(window).getSize().y - this.floaterSize().y
        };
      } else {
        return {
          position: "fixed",
          top: $(window).getSize().y - this.floaterSize().y
        };
      }
    };

    return Styles;

  })();
  return Styles;
});

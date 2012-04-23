
define(["jquery.custom", "core/helpers", "core/range/range.module", "core/range/range.coordinates"], function($, Helpers, Module, Coordinates) {
  var Range;
  Range = (function() {

    Range.EDITOR_ESCAPE_ERROR = new Object();

    Range.getBlankRange = function() {
      throw "Range.getBlankRange() needs to be overridden with a browser specific implementation";
    };

    Range.getRangeFromSelection = function() {
      throw "Range.getRangeFromSelection() needs to be overridden with a browser specific implementation";
    };

    Range.getRangeFromElement = function(el) {
      throw "Range.getRangeFromElement() needs to be overridden with a browser specific implementation";
    };

    function Range(el, arg) {
      this.el = el;
      if (!this.el) throw "new Range() is missing argument el";
      if (this.el.nodeType !== 1) throw "new Range() el is not an element";
      switch (Helpers.typeOf(arg)) {
        case "window":
          this.range = Range.getRangeFromSelection();
          break;
        case "element":
          this.range = Range.getRangeFromElement(arg);
          break;
        default:
          this.range = arg || Range.getBlankRange();
      }
    }

    Range.prototype.isCollapsed = function() {
      throw "#isCollapsed() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.isImageSelected = function() {
      throw "#isImageSelected() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.getCoordinates = function() {
      throw "#getCoordinates() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.getParentElement = function(match) {
      var el, matchFn;
      switch (Helpers.typeOf(match)) {
        case "function":
          matchFn = match;
          break;
        case "string":
          matchFn = function(el) {
            return $(el).filter(match).length > 0;
          };
          break;
        case "null":
          matchFn = function() {
            return true;
          };
          break;
        case "undefined":
          matchFn = function() {
            return true;
          };
          break;
        default:
          throw "invalid type for match";
      }
      el = this.getImmediateParentElement();
      if (!el) return null;
      try {
        while (true) {
          if (el === this.el || el === document.body) {
            el = null;
            break;
          } else if (matchFn(el)) {
            break;
          } else {
            el = el.parentNode;
          }
        }
      } catch (e) {
        if (e === Range.EDITOR_ESCAPE_ERROR) {
          el = null;
        } else {
          throw e;
        }
      }
      return el;
    };

    Range.prototype.collapse = function(start) {
      this.range.collapse(start);
      return this;
    };

    Range.prototype.select = function(range) {
      throw "#select() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.unselect = function() {
      throw "#unselect() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.selectEndOfElement = function(el) {
      throw "#selectEndOfElement() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.selectEndOfTableCell = function(cell) {
      throw "#selectEndOfTableCell() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.paste = function(arg) {
      switch (Helpers.typeOf(arg)) {
        case "string":
          return this.pasteHTML(arg);
        case "element":
          return this.pasteNode(arg);
        default:
          throw "Don't know how to paste this type of arg";
      }
    };

    Range.prototype.surroundContents = function(el) {
      throw "#surroundContents() needs to be overridden with a browser specific implementation";
    };

    Range.prototype.remove = function() {
      throw "#remove() needs to be overridden with a browser specific implementation";
    };

    return Range;

  })();
  Helpers.extend(Range, Module.static);
  Helpers.include(Range, Module.instance);
  Helpers.include(Range, Coordinates);
  return Range;
});

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(["jquery.custom", "core/helpers", "core/browser"], function($, Helpers, Browser) {
  var EraseHandler;
  EraseHandler = (function() {

    function EraseHandler() {
      this.onkeydown = __bind(this.onkeydown, this);
      this.deactivate = __bind(this.deactivate, this);
      this.activate = __bind(this.activate, this);
    }

    EraseHandler.prototype.register = function(api) {
      this.api = api;
      if (Browser.isWebkit) {
        this.api.on("activate.editor", this.activate);
        return this.api.on("deactivate.editor", this.deactivate);
      }
    };

    EraseHandler.prototype.activate = function() {
      return $(this.api.el).on("keydown", this.onkeydown);
    };

    EraseHandler.prototype.deactivate = function() {
      return $(this.api.el).off("keydown", this.onkeydown);
    };

    EraseHandler.prototype.onkeydown = function(e) {
      var key;
      key = Helpers.keyOf(e);
      if (key === 'delete' || key === 'backspace') {
        if (this.api.isCollapsed()) {
          return this.handleCursor(e);
        } else {
          return this.handleSelection(e);
        }
      }
    };

    EraseHandler.prototype.handleCursor = function(e) {
      var aNode, bNode, key, parentNode, range;
      range = this.api.range();
      parentNode = range.getParentElement(this.isBlockElement);
      key = Helpers.keyOf(e);
      if (key === 'delete' && range.isEndOfNode(parentNode)) {
        aNode = parentNode;
        bNode = $(parentNode).next()[0];
      } else if (key === 'backspace' && range.isStartOfNode(parentNode)) {
        aNode = $(parentNode).prev()[0];
        bNode = parentNode;
      }
      if (aNode) {
        e.preventDefault();
        return this.mergeNodes(aNode, bNode);
      }
    };

    EraseHandler.prototype.handleSelection = function(e) {
      var endParentNode, endRange, startParentNode, startRange;
      startRange = this.api.range().collapse(true);
      endRange = this.api.range().collapse(false);
      startParentNode = startRange.getParentElement(this.isBlockElement);
      endParentNode = endRange.getParentElement(this.isBlockElement);
      if (startParentNode !== endParentNode) {
        e.preventDefault();
        this.api.remove();
        return this.mergeNodes(startParentNode, endParentNode);
      }
    };

    EraseHandler.prototype.isBlockElement = function(el) {
      var $el;
      $el = $(el);
      return $el.css('display') === 'block' || $el.tagName() === 'li';
    };

    EraseHandler.prototype.mergeNodes = function(a, b) {
      var $span;
      $span = $('<span id="EDITOR_CURSOR_POS"></span>');
      $(a).append($span);
      while (b.childNodes[0]) {
        a.appendChild(b.childNodes[0]);
      }
      $(b).remove();
      a.normalize();
      this.api.range($span[0]).collapse(false).select();
      return $span.remove();
    };

    return EraseHandler;

  })();
  return EraseHandler;
});

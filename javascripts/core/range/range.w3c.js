
define(["jquery.custom", "core/helpers"], function($, Helpers) {
  return {
    static: {
      getBlankRange: function() {
        return document.createRange();
      },
      getRangeFromSelection: function() {
        return window.getSelection().getRangeAt(0).cloneRange();
      },
      getRangeFromElement: function(el) {
        var range;
        range = this.getBlankRange();
        range.selectNode(el);
        return range;
      }
    },
    instance: {
      isCollapsed: function() {
        return this.range.collapsed;
      },
      isImageSelected: function() {
        var div;
        div = $("<div/>").append(this.range.cloneContents())[0];
        return div.childNodes.length === 1 && div.childNodes[0].tagName.toLowerCase(0) === "img";
      },
      isStartOfNode: function(node) {
        var range, startText;
        range = this.range.cloneRange();
        range.setStartBefore(node);
        startText = $("<div/>").html(range.cloneContents()).text();
        return startText.match(/^[\n\t ]*$/);
      },
      isEndOfNode: function(node) {
        var endText, range;
        range = this.range.cloneRange();
        range.setEndAfter(node);
        endText = $("<div/>").html(range.cloneContents()).text();
        return endText.match(/^[\n\t ]*$/);
      },
      getImmediateParentElement: function() {
        var node;
        node = this.range.commonAncestorContainer;
        while (!Helpers.isElement(node)) {
          node = node.parentNode;
        }
        return node;
      },
      select: function(range) {
        var sel;
        range || (range = this.range);
        sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(range);
        this.range = range;
        return this;
      },
      unselect: function() {
        return window.getSelection().removeAllRanges();
      },
      selectEndOfElement: function(el) {
        var range;
        range = this.constructor.getBlankRange();
        range.selectNodeContents(el);
        range.collapse(false);
        this.select(range);
        return this.el.focus();
      },
      selectEndOfTableCell: function(cell) {
        return this.selectEndOfElement(cell);
      },
      selectAfterElement: function(el) {
        this.range.selectNode(el);
        this.range.collapse(false);
        return this.select();
      },
      pasteNode: function(node) {
        this.range.insertNode(node);
        return this.selectAfterElement(node);
      },
      pasteHTML: function(html) {
        var div, last, node;
        this.select();
        div = document.createElement("div");
        div.innerHTML = html;
        last = div.lastChild;
        while (div.childNodes.length > 0 && (node = div.childNodes[div.childNodes.length - 1])) {
          this.range.insertNode(node);
        }
        return this.selectAfterElement(last);
      },
      surroundContents: function(el) {
        this.range.surroundContents(el);
        return this.selectAfterElement(el);
      },
      remove: function() {
        return this.range.deleteContents();
      }
    }
  };
});

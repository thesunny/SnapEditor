
define(["core/helpers"], function(Helpers) {
  return {
    static: {
      getBlankRange: function() {
        return document.body.createTextRange();
      },
      getRangeFromSelection: function() {
        return document.selection.createRange();
      },
      getRangeFromElement: function(el) {
        var range;
        if (el.nodeName === 'IMG') {
          range = document.body.createControlRange();
          range.add(el);
        } else {
          range = document.body.createTextRange();
          range.moveToElementText(el);
        }
        return range;
      }
    },
    instance: {
      isCollapsed: function() {
        return this.range.text.length === 0;
      },
      isImageSelected: function() {
        return typeof this.range.parentElement === "undefined";
      },
      getImmediateParentElement: function() {
        return (this.range.parentElement && this.range.parentElement()) || null;
      },
      select: function(range) {
        range || (range = this.range);
        range.select();
        this.range = range;
        return this;
      },
      unselect: function() {
        return document.selection.empty();
      },
      selectEndOfTableCell: function(cell) {
        var range;
        range = this.constructor.getRangeFromElement(cell);
        range.collapse(false);
        return this.select(range);
      },
      pasteNode: function(node) {
        var div;
        div = document.createElement("div");
        div.appendChild(node);
        return this.pasteHTML(div.innerHTML);
      },
      pasteHTML: function(html) {
        this.select();
        return this.range.pasteHTML(html);
      },
      surroundContents: function(el) {
        el.innerHTML = this.range.htmlText;
        return this.pasteNode(el);
      },
      remove: function() {
        return this.range.execCommand('delete');
      }
    }
  };
});

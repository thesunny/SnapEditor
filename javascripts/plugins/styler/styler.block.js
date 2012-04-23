var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(["jquery.custom", "core/browser", "core/helpers"], function($, Browser, Helpers) {
  var BlockStyler;
  BlockStyler = (function() {

    function BlockStyler() {
      this.outdent = __bind(this.outdent, this);
      this.indent = __bind(this.indent, this);
      this.orderedList = __bind(this.orderedList, this);
      this.unorderedList = __bind(this.unorderedList, this);
      this.alignRight = __bind(this.alignRight, this);
      this.alignCenter = __bind(this.alignCenter, this);
      this.alignLeft = __bind(this.alignLeft, this);
      this.formatBlock = __bind(this.formatBlock, this);
      this.h3 = __bind(this.h3, this);
      this.h2 = __bind(this.h2, this);
      this.h1 = __bind(this.h1, this);
      this.p = __bind(this.p, this);
    }

    BlockStyler.prototype.register = function(api) {
      this.api = api;
    };

    BlockStyler.prototype.getDefaultToolbar = function() {
      return "Block";
    };

    BlockStyler.prototype.getToolbar = function(ui) {
      var alignCenter, alignLeft, alignRight, h1, h2, h3, indent, orderedList, outdent, p, unorderedList;
      p = ui.button({
        action: "p",
        attrs: {
          "class": "p-button",
          title: "Paragraph (Ctrl+Space)"
        }
      });
      h1 = ui.button({
        action: "h1",
        attrs: {
          "class": "h1-button",
          title: "H1 (Ctrl+1)"
        }
      });
      h2 = ui.button({
        action: "h2",
        attrs: {
          "class": "h2-button",
          title: "H2 (Ctrl+2)"
        }
      });
      h3 = ui.button({
        action: "h3",
        attrs: {
          "class": "h3-button",
          title: "H3 (Ctrl+3)"
        }
      });
      alignLeft = ui.button({
        action: "alignleft",
        attrs: {
          "class": "alignleft-button",
          title: "Align Left (Ctrl+L)"
        }
      });
      alignCenter = ui.button({
        action: "aligncenter",
        attrs: {
          "class": "aligncenter-button",
          title: "Align Center (Ctrl+E)"
        }
      });
      alignRight = ui.button({
        action: "alignright",
        attrs: {
          "class": "alignright-button",
          title: "Align Right (Ctrl+R)"
        }
      });
      unorderedList = ui.button({
        action: "unorderedlist",
        attrs: {
          "class": "unorderedlist-button",
          title: "Bullet List (Ctrl+8)"
        }
      });
      orderedList = ui.button({
        action: "orderedlist",
        attrs: {
          "class": "orderedlist-button",
          title: "Numbered List (Ctrl+7)"
        }
      });
      indent = ui.button({
        action: "indent",
        attrs: {
          "class": "indent-button",
          title: "Indent"
        }
      });
      outdent = ui.button({
        action: "outdent",
        attrs: {
          "class": "outdent-button",
          title: "Outdent"
        }
      });
      return {
        Block: [p, h1, h2, h3, alignLeft, alignCenter, alignRight, unorderedList, orderedList, indent, outdent],
        P: p,
        H1: h1,
        H2: h2,
        H3: h3,
        AlignLeft: alignLeft,
        AlignCenter: alignCenter,
        AlignRight: alignRight,
        UnorderedList: unorderedList,
        OrderedList: orderedList,
        Indent: indent,
        Outdent: outdent
      };
    };

    BlockStyler.prototype.getToolbarActions = function() {
      return {
        p: this.p,
        h1: this.h1,
        h2: this.h2,
        h3: this.h3,
        alignleft: this.alignLeft,
        aligncenter: this.alignCenter,
        alignright: this.alignRight,
        unorderedlist: this.unorderedList,
        orderedlist: this.orderedList,
        indent: this.indent,
        outdent: this.outdent
      };
    };

    BlockStyler.prototype.getKeyboardShortcuts = function() {
      return {
        "ctrl.space": this.p,
        "ctrl.1": this.h1,
        "ctrl.2": this.h2,
        "ctrl.3": this.h3,
        "ctrl.l": this.alignLeft,
        "ctrl.e": this.alignCenter,
        "ctrl.r": this.alignRight,
        "ctrl.8": this.unorderedList,
        "ctrl.7": this.orderedList
      };
    };

    BlockStyler.prototype.p = function() {
      this.formatBlock('p');
      return this.update();
    };

    BlockStyler.prototype.h1 = function() {
      this.formatBlock('h1');
      return this.update();
    };

    BlockStyler.prototype.h2 = function() {
      this.formatBlock('h2');
      return this.update();
    };

    BlockStyler.prototype.h3 = function() {
      this.formatBlock('h3');
      return this.update();
    };

    BlockStyler.prototype.formatBlock = function(tag) {
      this.exec("formatblock", "<" + tag + ">");
      return this.update();
    };

    BlockStyler.prototype.alignLeft = function() {
      return this.align("left");
    };

    BlockStyler.prototype.alignCenter = function() {
      return this.align("center");
    };

    BlockStyler.prototype.alignRight = function() {
      return this.align("right");
    };

    BlockStyler.prototype.align = function(position) {
      var ceNode, command, dummy, range;
      command = "justify" + (Helpers.capitalize(position));
      try {
        this.exec(command);
      } catch (e) {
        if (e && e.result === 2147500037) {
          range = window.getSelection().getRangeAt(0);
          dummy = document.createElement('span');
          ceNode = this.el;
          ceNode.insertBefore(dummy, ceNode.childNodes[0]);
          this.exec(command);
          dummy.parentNode.removeChild(dummy);
        } else if (console && console.log) {
          console.log(e);
        }
      }
      return this.update();
    };

    BlockStyler.prototype.unorderedList = function() {
      this.exec("insertunorderedlist");
      return this.update();
    };

    BlockStyler.prototype.orderedList = function() {
      this.exec("insertorderedlist");
      return this.update();
    };

    BlockStyler.prototype.indent = function() {
      this.exec("indent");
      return this.update();
    };

    BlockStyler.prototype.outdent = function() {
      this.exec("outdent");
      return this.update();
    };

    BlockStyler.prototype.exec = function(cmd, value) {
      if (value == null) value = null;
      return document.execCommand(cmd, false, value);
    };

    BlockStyler.prototype.update = function() {
      if (Browser.isMozilla) this.api.el.focus();
      return this.api.update();
    };

    return BlockStyler;

  })();
  return BlockStyler;
});

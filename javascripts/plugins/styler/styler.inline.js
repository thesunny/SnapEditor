var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(["jquery.custom", "core/browser"], function($, Browser) {
  var InlineStyler;
  InlineStyler = (function() {

    function InlineStyler() {
      this.link = __bind(this.link, this);
      this.italic = __bind(this.italic, this);
      this.bold = __bind(this.bold, this);
    }

    InlineStyler.prototype.register = function(api) {
      this.api = api;
    };

    InlineStyler.prototype.getDefaultToolbar = function() {
      return "Inline";
    };

    InlineStyler.prototype.getToolbar = function(ui) {
      var bold, italic, link;
      bold = ui.button({
        action: "bold",
        attrs: {
          "class": "bold-button",
          title: "Bold (Ctrl+B)"
        }
      });
      italic = ui.button({
        action: "italic",
        attrs: {
          "class": "italic-button",
          title: "Italic (Ctrl+I)"
        }
      });
      link = ui.button({
        action: "link",
        attrs: {
          "class": "link-button",
          title: "Insert Link (Ctrl+K)"
        }
      });
      return {
        Inline: [bold, italic, link],
        Bold: bold,
        Italic: italic,
        Link: link
      };
    };

    InlineStyler.prototype.getToolbarActions = function() {
      return {
        bold: this.bold,
        italic: this.italic,
        link: this.link
      };
    };

    InlineStyler.prototype.getKeyboardShortcuts = function() {
      return {
        "ctrl.b": this.bold,
        "ctrl.i": this.italic,
        "ctrl.k": this.link
      };
    };

    InlineStyler.prototype.bold = function() {
      return this.format("b");
    };

    InlineStyler.prototype.italic = function() {
      return this.format("i");
    };

    InlineStyler.prototype.format = function(tag) {
      if (Browser.isGecko) document.execCommand("styleWithCSS", false, false);
      switch (tag) {
        case "b":
          this.exec("bold");
          break;
        case "i":
          this.exec("italic");
          break;
        default:
          throw "The inline style for tag " + tag + " is unsupported";
      }
      return this.update();
    };

    InlineStyler.prototype.link = function() {
      var href, link, parentLink;
      href = prompt("Enter URL of link", "http://");
      if (href) {
        href = $.trim(href);
        parentLink = this.api.getParentElement("a");
        if (parentLink) {
          $(parentLink).attr("href", href);
        } else if (this.api.isCollapsed()) {
          link = $("<a href=\"" + href + "\">" + href + "</a>");
          this.api.paste(link[0]);
        } else {
          link = $("<a href=\"" + href + "\"></a>");
          this.api.surroundContents(link[0]);
        }
        return this.update();
      }
    };

    InlineStyler.prototype.update = function() {
      return this.api.update();
    };

    InlineStyler.prototype.exec = function(command, value) {
      if (value == null) value = null;
      return document.execCommand(command, false, value);
    };

    return InlineStyler;

  })();
  return InlineStyler;
});

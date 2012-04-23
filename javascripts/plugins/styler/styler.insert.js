var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(["jquery.custom", "core/browser", "core/helpers"], function($, Browser, Helpers) {
  var BlockStyler;
  BlockStyler = (function() {

    function BlockStyler(options) {
      if (options == null) options = {};
      this.table = __bind(this.table, this);
      this.link = __bind(this.link, this);
      this.options = {
        table: [2, 3]
      };
      $.extend(this.options, options);
    }

    BlockStyler.prototype.register = function(api) {
      this.api = api;
    };

    BlockStyler.prototype.getDefaultToolbar = function() {
      return "Insert";
    };

    BlockStyler.prototype.getToolbar = function(ui) {
      var link, table;
      link = ui.button({
        action: "link",
        attrs: {
          "class": "link-button",
          title: "Insert Link (Ctrl+K)"
        }
      });
      table = ui.button({
        action: "table",
        attrs: {
          "class": "table-button",
          title: "Insert Table (Ctrl+Shift+T)"
        }
      });
      return {
        Insert: [link, table],
        Link: link,
        Table: table
      };
    };

    BlockStyler.prototype.getToolbarActions = function() {
      return {
        link: this.link,
        table: this.table
      };
    };

    BlockStyler.prototype.getKeyboardShortcuts = function() {
      return {
        "ctrl.k": this.link,
        "ctrl.shift.t": this.table
      };
    };

    BlockStyler.prototype.link = function() {
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

    BlockStyler.prototype.table = function() {
      var i, table, tbody, td, tr, _ref, _ref2;
      table = $('<table id="INSERTED_TABLE"></table>');
      tbody = $("<tbody/>").appendTo(table);
      td = $("<td>&nbsp;</td>");
      tr = $("<tr/>");
      for (i = 1, _ref = this.options.table[1]; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
        tr.append(td.clone());
      }
      for (i = 1, _ref2 = this.options.table[0]; 1 <= _ref2 ? i <= _ref2 : i >= _ref2; 1 <= _ref2 ? i++ : i--) {
        tbody.append(tr.clone());
      }
      this.api.paste(table[0]);
      table = $("#INSERTED_TABLE");
      this.api.selectEndOfTableCell(table.find("td")[0]);
      table.removeAttr("id");
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

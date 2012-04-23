
define(["jquery.custom", "core/helpers", "core/events", "core/range"], function($, Helpers, Events, Range) {
  var API;
  API = (function() {

    function API(editor) {
      this.editor = editor;
      this.el = this.editor.$el[0];
      Helpers.delegate(this, "editor", "contents", "activate", "deactivate", "update");
      Helpers.delegate(this, "range()", "isCollapsed", "isImageSelected", "getCoordinates", "getParentElement", "collapse", "unselect", "selectEndOfTableCell", "paste", "surroundContents", "remove");
    }

    API.prototype.range = function(el) {
      return new Range(this.el, el || window);
    };

    API.prototype.select = function(el) {
      return this.range(el).select();
    };

    return API;

  })();
  Helpers.include(API, Events);
  return API;
});

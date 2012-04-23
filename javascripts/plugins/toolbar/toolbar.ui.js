
define(["jquery.custom"], function($) {
  var ToolbarUI;
  ToolbarUI = (function() {

    function ToolbarUI(templates) {
      this.$templates = $(templates);
      this.setupTemplates();
    }

    ToolbarUI.prototype.setupTemplates = function() {
      this.$buttonTemplate = this.$templates.find("#snapeditor_toolbar_button_template");
      this.$selectTemplate = this.$templates.find("#snapeditor_toolbar_select_template");
      return this.checkTemplates();
    };

    ToolbarUI.prototype.checkTemplates = function() {
      if (this.$buttonTemplate.length === 0) {
        throw "Missing template. Make sure there is an element with id snapeditor_toolbar_button_template.";
      }
    };

    ToolbarUI.prototype.button = function(options) {
      var attr, attrs, value, _ref,
        _this = this;
      if (options == null) options = {};
      if (!options.action) {
        throw "The toolbar's ui.button() expects an 'action' option";
      }
      if (options.attrs) {
        attrs = "";
        _ref = options.attrs;
        for (attr in _ref) {
          value = _ref[attr];
          attrs += "" + attr + "=\"" + value + "\" ";
        }
        options.attrs = attrs;
      }
      return function() {
        return _this.$buttonTemplate.mustache(options);
      };
    };

    return ToolbarUI;

  })();
  return ToolbarUI;
});

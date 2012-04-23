
define(["jquery.custom", "core/helpers"], function($, Helpers) {
  var ToolbarBuilder;
  ToolbarBuilder = (function() {

    function ToolbarBuilder(templates, availableButtons, buttons) {
      this.availableButtons = availableButtons;
      this.buttons = buttons;
      this.$templates = $(templates);
    }

    ToolbarBuilder.prototype.build = function() {
      var $toolbar;
      this.setupTemplates();
      $toolbar = $(this.toolbarTemplate.mustache({
        buttonGroups: this.getButtons()
      }));
      $toolbar.find("[data-action]").each(function() {
        return $(this).attr("unselectable", "on");
      });
      return $toolbar;
    };

    ToolbarBuilder.prototype.setupTemplates = function() {
      var _this = this;
      this.toolbarTemplate = this.$templates.find("#snapeditor_toolbar_template");
      this.gapTemplate = this.$templates.find("#snapeditor_toolbar_button_gap_template");
      this.checkTemplates();
      return this.availableButtons["-"] = function() {
        return _this.gapTemplate.html();
      };
    };

    ToolbarBuilder.prototype.checkTemplates = function() {
      if (this.toolbarTemplate.length === 0) {
        throw "Missing template. Make sure there is an element with id snapeditor_toolbar_template.";
      }
      if (this.gapTemplate.length === 0) {
        throw "Missing template. Make sure there is an element with id snapeditor_toolbar_button_gap_template.";
      }
    };

    ToolbarBuilder.prototype.getButtons = function() {
      var button, htmlButtonGroups, htmlButtons, _i, _len, _ref;
      htmlButtonGroups = [];
      htmlButtons = [];
      _ref = this.buttons;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        button = _ref[_i];
        if (button === "|") {
          htmlButtonGroups.push({
            buttons: htmlButtons
          });
          htmlButtons = [];
        } else {
          htmlButtons.push({
            html: this.getButtonHtml(button)
          });
        }
      }
      if (htmlButtons.length !== 0) {
        htmlButtonGroups.push({
          buttons: htmlButtons
        });
      }
      return htmlButtonGroups;
    };

    ToolbarBuilder.prototype.getButtonHtml = function(button) {
      var renderer;
      renderer = this.availableButtons[button];
      if (!renderer) {
        throw "The button(s) for " + button + " is not available. Please check that the plugin has been included.";
      }
      return this.renderButton(button, renderer);
    };

    ToolbarBuilder.prototype.renderButton = function(button, renderer) {
      var html, output, r, _i, _len;
      renderer = this.normalizeRenderer(renderer);
      output = renderer();
      switch (Helpers.typeOf(output)) {
        case "string":
          html = output;
          break;
        case "array":
          html = "";
          for (_i = 0, _len = output.length; _i < _len; _i++) {
            r = output[_i];
            html += this.renderButton(button, r);
          }
          break;
        default:
          throw "Unrecognized button format for '" + button + "'. The renderer should return an HTML string or an array of renderers.";
      }
      return html;
    };

    ToolbarBuilder.prototype.normalizeRenderer = function(renderer) {
      if (Helpers.typeOf(renderer) === "function") return renderer;
      return function() {
        return renderer;
      };
    };

    return ToolbarBuilder;

  })();
  return ToolbarBuilder;
});

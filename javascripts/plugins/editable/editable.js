
define(["jquery.custom", "core/browser", "core/helpers", "plugins/editable/editable.others", "plugins/editable/editable.ie"], function($, Browser, Helpers, Others, IE) {
  var Editable, Module;
  Editable = (function() {

    function Editable() {}

    Editable.prototype.register = function(api) {
      var _this = this;
      this.api = api;
      return this.api.on("click.activate", function() {
        return _this.start.apply(_this);
      });
    };

    Editable.prototype.start = function() {
      throw "Editable.start() needs to be overridden with a browser specific implementation";
    };

    Editable.prototype.deactivate = function() {
      this.el.contentEditable = false;
      this.el.blur();
      return this.deactivateBrowser();
    };

    Editable.prototype.deactivateBrowser = function() {};

    return Editable;

  })();
  Module = Browser.isIE ? IE : Others;
  Helpers.include(Editable, Module);
  return Editable;
});

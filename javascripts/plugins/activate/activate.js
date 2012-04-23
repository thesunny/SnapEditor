var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(["jquery.custom", "core/browser", "core/helpers", "core/events", "plugins/activate/activate.others", "plugins/activate/activate.ie"], function($, Browser, Helpers, Events, Others, IE) {
  var Activate;
  Activate = (function() {

    function Activate() {
      this.deactivate = __bind(this.deactivate, this);
    }

    Activate.prototype.register = function(api) {
      this.api = api;
      return this.addActivateEvents();
    };

    Activate.prototype.addActivateEvents = function() {
      throw "#addActivateEvents() needs to be overridden with a browser specific implementation";
    };

    Activate.prototype.click = function() {
      return this.api.trigger("click.activate");
    };

    Activate.prototype.activate = function() {
      this.api.activate();
      return this.api.on("deactivate.editor", this.deactivate);
    };

    Activate.prototype.deactivate = function() {
      this.api.off("deactivate.editor", this.deactivate);
      return this.addActivateEvents();
    };

    Activate.prototype.isLink = function(el) {
      var $el;
      $el = $(el);
      return $el.tagName() === 'a' || $el.parent('a').length !== 0;
    };

    return Activate;

  })();
  Helpers.include(Activate, Browser.isIE ? IE : Others);
  return Activate;
});

var __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

define(["plugins/toolbar/toolbar"], function(Toolbar) {
  var StaticToolbar;
  StaticToolbar = (function(_super) {

    __extends(StaticToolbar, _super);

    function StaticToolbar() {
      StaticToolbar.__super__.constructor.apply(this, arguments);
    }

    StaticToolbar.prototype.register = function(api) {
      this.api = api;
      this.setup();
      return this.$toolbar.hide().appendTo("body");
    };

    StaticToolbar.prototype.show = function() {
      return this.$toolbar.show();
    };

    return StaticToolbar;

  })(Toolbar);
  return StaticToolbar;
});

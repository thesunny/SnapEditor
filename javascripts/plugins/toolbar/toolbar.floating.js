var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

define(["plugins/toolbar/toolbar", "plugins/toolbar/toolbar.floating.displayer"], function(Toolbar, Displayer) {
  var FloatingToolbar;
  FloatingToolbar = (function(_super) {

    __extends(FloatingToolbar, _super);

    function FloatingToolbar() {
      this.hide = __bind(this.hide, this);
      this.show = __bind(this.show, this);
      FloatingToolbar.__super__.constructor.apply(this, arguments);
    }

    FloatingToolbar.prototype.register = function(api) {
      this.api = api;
      this.api.on("activate.editor", this.show);
      return this.api.on("deactivate.editor", this.hide);
    };

    FloatingToolbar.prototype.setup = function() {
      FloatingToolbar.__super__.setup.apply(this, arguments);
      return this.displayer = new Displayer(this.$toolbar, this.api.el, this.api);
    };

    FloatingToolbar.prototype.show = function() {
      if (!this.$toolbar) this.setup();
      return this.displayer.show();
    };

    FloatingToolbar.prototype.hide = function() {
      if (this.$toolbar) return this.displayer.hide();
    };

    return FloatingToolbar;

  })(Toolbar);
  return FloatingToolbar;
});

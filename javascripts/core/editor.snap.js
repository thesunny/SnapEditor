var __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

define(["core/editor", "config/config.default.snap", "plugins/toolbar/toolbar.floating"], function(Editor, Defaults, Toolbar) {
  var SnapEditor;
  SnapEditor = (function(_super) {

    __extends(SnapEditor, _super);

    function SnapEditor(el, config) {
      SnapEditor.__super__.constructor.call(this, el, Defaults.build(), config);
    }

    SnapEditor.prototype.setupPlugins = function() {
      SnapEditor.__super__.setupPlugins.apply(this, arguments);
      this.toolbar = new Toolbar(this.$templates, this.defaultToolbarPlugins, this.toolbarPlugins, this.defaults.toolbar, this.config.toolbar);
      return this.registerPlugin(this.toolbar);
    };

    return SnapEditor;

  })(Editor);
  return SnapEditor;
});

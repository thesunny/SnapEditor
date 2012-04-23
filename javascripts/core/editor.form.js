var __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

define(["core/editor", "config/config.default.form", "plugins/toolbar/toolbar.static", "plugins/formizer/formizer"], function(Editor, Defaults, Toolbar, Formizer) {
  var FormEditor;
  FormEditor = (function(_super) {

    __extends(FormEditor, _super);

    function FormEditor(el, config) {
      FormEditor.__super__.constructor.call(this, el, Defaults.build(), config);
    }

    FormEditor.prototype.setupPlugins = function() {
      FormEditor.__super__.setupPlugins.apply(this, arguments);
      this.toolbar = new Toolbar(this.$templates, this.defaultToolbarPlugins, this.toolbarPlugins, this.defaults.toolbar, this.config.toolbar);
      this.registerPlugin(this.toolbar);
      this.formizer = new Formizer(this.$el, this.toolbar.$toolbar);
      return this.formizer.call();
    };

    return FormEditor;

  })(Editor);
  return FormEditor;
});

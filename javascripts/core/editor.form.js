var __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

define(["core/editor", "config/config.default.form", "plugins/toolbar/toolbar.static", "plugins/formizer/formizer"], function(Editor, Defaults, Toolbar, Formizer) {
  var FormEditor;
  FormEditor = (function(_super) {

    __extends(FormEditor, _super);

    function FormEditor(el, config) {
      this.formizer = new Formizer($(el));
      FormEditor.__super__.constructor.call(this, this.formizer.$content, Defaults.build(), config);
      this.formizer.formize(this.toolbar.$toolbar);
    }

    FormEditor.prototype.setupPlugins = function() {
      FormEditor.__super__.setupPlugins.apply(this, arguments);
      this.toolbar = new Toolbar(this.$templates, this.defaultToolbarPlugins, this.toolbarPlugins, this.defaults.toolbar, this.config.toolbar);
      return this.registerPlugin(this.toolbar);
    };

    return FormEditor;

  })(Editor);
  return FormEditor;
});

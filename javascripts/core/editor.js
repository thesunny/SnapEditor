
define(["jquery.custom", "core/api", "config/config.default", "plugins/keyboard/keyboard"], function($, API, Defaults, Keyboard) {
  var Editor;
  Editor = (function() {

    function Editor(el, defaults, config) {
      if (defaults == null) defaults = {};
      this.config = config != null ? config : {};
      this.$el = $(el);
      this.api = new API(this);
      this.defaultToolbarPlugins = [];
      this.toolbarPlugins = [];
      this.keyboardPlugins = [];
      this.loadAssets();
      this.setupDefaults(defaults);
      this.setupPlugins();
    }

    Editor.prototype.setupDefaults = function(defaults) {
      this.defaults = Defaults.build();
      if (defaults.plugins) {
        this.defaults.plugins = this.defaults.plugins.concat(defaults.plugins);
      }
      if (defaults.toolbar) return this.defaults.toolbar = defaults.toolbar;
    };

    Editor.prototype.loadAssets = function() {
      this.loadTemplates();
      return this.loadCSS();
    };

    Editor.prototype.loadTemplates = function() {
      var _this = this;
      return $.ajax({
        url: this.config.assets.templates,
        async: false,
        success: function(html) {
          return _this.$templates = $("<div/>").html(html);
        }
      });
    };

    Editor.prototype.loadCSS = function() {
      if (this.config.assets.css) {
        return $("<link href=\"" + this.config.assets.css + "\" rel=\"stylesheet\" type=\"text/css\">").appendTo("head");
      }
    };

    Editor.prototype.setupPlugins = function() {
      this.registerPlugins(this.defaults.plugins, true);
      if (this.config.plugins) this.registerPlugins(this.config.plugins);
      this.keyboard = new Keyboard(this.keyboardPlugins, "keydown", this.$el);
      return this.registerPlugin(this.keyboard);
    };

    Editor.prototype.registerPlugins = function(plugins, isDefault) {
      var plugin, _i, _len, _results;
      if (isDefault == null) isDefault = false;
      _results = [];
      for (_i = 0, _len = plugins.length; _i < _len; _i++) {
        plugin = plugins[_i];
        _results.push(this.registerPlugin(plugin, isDefault));
      }
      return _results;
    };

    Editor.prototype.registerPlugin = function(plugin, isDefault) {
      if (isDefault == null) isDefault = false;
      plugin.register(this.api);
      if (plugin.getToolbar) this.addToolbarPlugin(plugin, isDefault);
      if (plugin.getKeyboardShortcuts) return this.addKeyboardPlugin(plugin);
    };

    Editor.prototype.addToolbarPlugin = function(plugin, isDefault) {
      if (isDefault == null) isDefault = false;
      if (!plugin.getDefaultToolbar) {
        throw "The toolbar plugin is missing a default: " + plugin + ", " + isDefault;
      }
      if (isDefault) {
        return this.defaultToolbarPlugins.push(plugin);
      } else {
        return this.toolbarPlugins.push(plugin);
      }
    };

    Editor.prototype.addKeyboardPlugin = function(plugin) {
      return this.keyboardPlugins.push(plugin);
    };

    Editor.prototype.activate = function() {
      this.api.trigger("activate.editor");
      return this.api.trigger("ready.editor");
    };

    Editor.prototype.deactivate = function() {
      return this.api.trigger("deactivate.editor");
    };

    Editor.prototype.update = function() {
      return this.api.trigger("update.editor");
    };

    Editor.prototype.contents = function() {
      return this.$el.html();
    };

    return Editor;

  })();
  return Editor;
});

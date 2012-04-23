
define(["jquery.custom", "core/data_action_handler", "plugins/toolbar/toolbar.ui", "plugins/toolbar/toolbar.builder"], function($, DataActionHandler, UI, Builder) {
  var Toolbar;
  Toolbar = (function() {

    function Toolbar(templates, defaultPlugins, plugins, defaultButtons, buttons) {
      this.defaultPlugins = defaultPlugins;
      this.plugins = plugins;
      if (defaultButtons == null) defaultButtons = [];
      this.buttons = buttons != null ? buttons : [];
      this.namespace = "toolbar";
      this.$toolbar = null;
      this.customButtons = this.buttons.length > 0;
      if (!this.customButtons) this.buttons = defaultButtons;
      this.$templates = $(templates);
      this.ui = new UI(this.$templates);
    }

    Toolbar.prototype.register = function(api) {
      this.api = api;
    };

    Toolbar.prototype.setup = function() {
      this.setupPlugins();
      this.$toolbar = new Builder(this.$templates, this.availableButtons, this.buttons).build();
      return this.dataActionHandler = new DataActionHandler(this.$toolbar, this.api, this.namespace);
    };

    Toolbar.prototype.setupPlugins = function() {
      var plugin, _i, _j, _len, _len2, _ref, _ref2, _results;
      this.availableButtons = {};
      _ref = this.defaultPlugins;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        plugin = _ref[_i];
        this.addPlugin(plugin, true);
      }
      _ref2 = this.plugins;
      _results = [];
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        plugin = _ref2[_j];
        _results.push(this.addPlugin(plugin));
      }
      return _results;
    };

    Toolbar.prototype.addPlugin = function(plugin, isDefault) {
      if (isDefault == null) isDefault = false;
      if (!plugin.getDefaultToolbar) {
        throw "The toolbar plugin is missing a default: " + plugin + ", " + isDefault;
      }
      $.extend(this.availableButtons, plugin.getToolbar(this.ui));
      if (plugin.getToolbarActions) this.addActions(plugin);
      if (!(isDefault || this.customButtons)) {
        if (this.buttons.length !== 0) this.buttons.push("|");
        return this.buttons.push(plugin.getDefaultToolbar());
      }
    };

    Toolbar.prototype.addActions = function(plugin) {
      var action, event, _ref, _results;
      _ref = plugin.getToolbarActions();
      _results = [];
      for (event in _ref) {
        action = _ref[event];
        _results.push(this.addAction(plugin, event, action));
      }
      return _results;
    };

    Toolbar.prototype.addAction = function(plugin, event, action) {
      return this.api.on("" + event + "." + this.namespace, function() {
        return action.apply(plugin, arguments);
      });
    };

    return Toolbar;

  })();
  return Toolbar;
});

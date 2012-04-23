var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty;

define(["jquery.custom", "core/helpers"], function($, Helpers) {
  var Keyboard;
  Keyboard = (function() {

    function Keyboard(plugins, type, el) {
      this.plugins = plugins;
      this.type = type;
      if (el == null) el = document.body;
      this.onkeydown = __bind(this.onkeydown, this);
      this.stop = __bind(this.stop, this);
      this.start = __bind(this.start, this);
      this.$el = $(el);
      this.keys = {};
      this.setupPlugins();
    }

    Keyboard.prototype.register = function(api) {
      this.api = api;
      this.api.on("activate.editor", this.start);
      return this.api.off("deactivate.editor", this.stop);
    };

    Keyboard.prototype.setupPlugins = function() {
      var plugin, _i, _len, _ref, _results;
      _ref = this.plugins;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        plugin = _ref[_i];
        _results.push(this.add(plugin.getKeyboardShortcuts()));
      }
      return _results;
    };

    Keyboard.prototype.add = function() {
      var arglen, fn, key, _ref, _results;
      arglen = arguments.length;
      if (arglen === 1) {
        if (!$.isPlainObject(arguments[0])) throw "Expected a map object";
        _ref = arguments[0];
        _results = [];
        for (key in _ref) {
          if (!__hasProp.call(_ref, key)) continue;
          fn = _ref[key];
          _results.push(this.add(key, fn));
        }
        return _results;
      } else if (arglen === 2) {
        return this.keys[this.normalize(arguments[0])] = arguments[1];
      } else {
        throw "Wrong number of arguments to Keyboard#add";
      }
    };

    Keyboard.prototype.remove = function() {
      var key, _i, _len, _ref, _results;
      if ($.isArray(arguments[0])) {
        _ref = arguments[0];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          key = _ref[_i];
          _results.push(this.remove(key));
        }
        return _results;
      } else {
        return delete this.keys[this.normalize(arguments[0])];
      }
    };

    Keyboard.prototype.start = function() {
      return this.$el.on(this.type, this.onkeydown);
    };

    Keyboard.prototype.stop = function() {
      return this.$el.off(this.type, this.onkeydown);
    };

    Keyboard.prototype.normalize = function(key) {
      var char, keys;
      keys = key.split('.');
      char = keys.pop();
      return this.buildKey(char, keys);
    };

    Keyboard.prototype.buildKey = function(key, specialKeys, delim) {
      var keys;
      if (specialKeys == null) specialKeys = [];
      if (delim == null) delim = '.';
      keys = specialKeys.sort();
      keys.push(key);
      return keys.join(delim);
    };

    Keyboard.prototype.onkeydown = function(e) {
      var fn, key;
      key = this.keyFromEvent(e);
      fn = this.keys[key];
      if (fn) {
        e.preventDefault();
        return fn();
      }
    };

    Keyboard.prototype.keyFromEvent = function(e) {
      var key, specialKeys;
      key = Helpers.keyOf(e);
      specialKeys = [];
      if (e.altKey) specialKeys.push('alt');
      if (e.ctrlKey) specialKeys.push('ctrl');
      if (e.shiftKey) specialKeys.push('shift');
      return this.buildKey(key, specialKeys);
    };

    return Keyboard;

  })();
  return Keyboard;
});

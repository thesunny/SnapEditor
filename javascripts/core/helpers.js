var __slice = Array.prototype.slice,
  __hasProp = Object.prototype.hasOwnProperty;

define(["jquery.custom"], function($) {
  return {
    nodeType: {
      ELEMENT: 1,
      TEXT: 3
    },
    isElement: function(object) {
      return object.nodeName && object.nodeType === this.nodeType.ELEMENT;
    },
    isTextnode: function(object) {
      return object.nodeName && object.nodeType === this.nodeType.TEXT;
    },
    typeOf: function(object) {
      var type;
      type = $.type(object);
      if (type !== "object") return type;
      if (this.isElement(object)) return "element";
      if (this.isTextnode(object)) return "textnode";
      if ($.isWindow(object)) return "window";
      return type;
    },
    extend: function(klass, module) {
      return $.extend(klass, module);
    },
    include: function(klass, module) {
      var key, value, _results;
      _results = [];
      for (key in module) {
        value = module[key];
        _results.push(klass.prototype[key] = value);
      }
      return _results;
    },
    delegate: function() {
      var del, delFn, fn, fns, isDelFn, object, _i, _len, _results;
      object = arguments[0], del = arguments[1], fns = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      isDelFn = del.slice(-2) === "()";
      if (isDelFn) del = del.substring(0, del.length - 2);
      delFn = function(object, fn) {
        return object[fn] = function() {
          var delObject;
          delObject = object[del];
          if (isDelFn) delObject = delObject.apply(object);
          return delObject[fn].apply(delObject, arguments);
        };
      };
      _results = [];
      for (_i = 0, _len = fns.length; _i < _len; _i++) {
        fn = fns[_i];
        if (typeof object[fn] !== "undefined") {
          throw "Delegate: " + fn + " is already defined on " + object;
        }
        if (typeof object[del] === "undefined") {
          throw "Delegate: " + del + " does not exist on " + object;
        }
        _results.push(delFn(object, fn));
      }
      return _results;
    },
    keys: {
      enter: 13,
      up: 38,
      down: 40,
      left: 37,
      right: 39,
      esc: 27,
      space: 32,
      backspace: 8,
      tab: 9,
      "delete": 46
    },
    keyOf: function(event) {
      var fKey, k, key, v, _ref;
      if (event.type === 'keydown') {
        fKey = event.which - 111;
        if ((0 < fKey && fKey < 13)) key = 'f' + fKey;
      }
      if (!key) {
        _ref = this.keys;
        for (k in _ref) {
          if (!__hasProp.call(_ref, k)) continue;
          v = _ref[k];
          if (v === event.which) key = k;
        }
        if (!key) key = String.fromCharCode(event.which).toLowerCase();
      }
      return key;
    },
    pass: function(fn, args, bind) {
      return function() {
        return fn.apply(bind, $.makeArray(args));
      };
    },
    capitalize: function(string) {
      return string.replace(/\b[a-z]/g, function(match) {
        return match.toUpperCase();
      });
    }
  };
});

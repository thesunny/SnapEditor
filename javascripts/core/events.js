
define(["jquery.custom"], function($) {
  return {
    get$eventEl: function() {
      return this.$eventEl || (this.$eventEl = $("<div/>"));
    },
    on: function() {
      var _ref;
      return (_ref = this.get$eventEl()).on.apply(_ref, arguments);
    },
    off: function() {
      var _ref;
      return (_ref = this.get$eventEl()).off.apply(_ref, arguments);
    },
    trigger: function() {
      var _ref;
      return (_ref = this.get$eventEl()).trigger.apply(_ref, arguments);
    }
  };
});

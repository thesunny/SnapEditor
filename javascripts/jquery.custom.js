
define(["../lib/jquery", "../lib/mustache"], function() {
  var $;
  $ = jQuery;
  $.noConflict();
  $.fn.tagName = function() {
    return this[0].tagName.toLowerCase();
  };
  $.fn.getCoordinates = function() {
    var height, offset, width;
    offset = this.offset();
    width = this.width();
    height = this.height();
    return {
      top: offset.top,
      bottom: offset.top + height,
      left: offset.left,
      right: offset.left + width,
      width: width,
      height: height
    };
  };
  $.fn.getScroll = function() {
    return {
      x: this.scrollLeft(),
      y: this.scrollTop()
    };
  };
  $.fn.getSize = function() {
    return {
      x: this.width(),
      y: this.height()
    };
  };
  $.fn.isVisible = function() {
    var el;
    el = this.get(0);
    return !!(el.offsetHeight || el.offsetWidth);
  };
  $.fn.measure = function(fn) {
    var parent, res, restore, result, toMeasure, _i, _len;
    if (this.isVisible()) return fn.call(this);
    parent = this.parent();
    toMeasure = [];
    while (!parent.isVisible() && parent.get(0) !== document.body) {
      toMeasure.push(parent.expose());
      parent = parent.parent();
    }
    restore = this.expose();
    result = fn.call(this);
    restore();
    for (_i = 0, _len = toMeasure.length; _i < _len; _i++) {
      res = toMeasure[_i];
      res();
    }
    return result;
  };
  $.fn.expose = function() {
    var before, el,
      _this = this;
    if (this.css("display") !== 'none') return function() {};
    el = this.get(0);
    before = el.style.cssText;
    this.css({
      display: 'block',
      position: 'absolute',
      visibility: 'hidden'
    });
    return function() {
      return el.style.cssText = before;
    };
  };
  $.mustache = function(template, view, partials) {
    return Mustache.render(template, view, partials);
  };
  $.fn.mustache = function(view, partials) {
    var output, template;
    template = $.trim($(this).html());
    return output = $.mustache(template, view, partials);
  };
  return $;
});

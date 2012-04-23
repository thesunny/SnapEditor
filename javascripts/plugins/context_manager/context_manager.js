var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(["jquery.custom"], function($) {
  var ContextManager;
  ContextManager = (function() {
    /*
          Editor.ContextManager takes callbacks corresponding to when certain
          contexts have been entered.
    
            * showBlock
            * hideBlock
            * showTable
            * hideTable
            * showList
            * hideList
            * showImage
            * hideImage
    
          Originally each toolbar handled its own show/hide logic but this method
          was implemented because it reduced processing overhead. Instead of doing
          a full range check for each toolbar to see if the toolbar is valid, we
          instead do a single check for all toolbars.
    */
    function ContextManager() {
      this.updateMode = __bind(this.updateMode, this);
      this.matchElement = __bind(this.matchElement, this);
      this.updateByRange = __bind(this.updateByRange, this);
      this.onmouseup = __bind(this.onmouseup, this);
      this.onkeyup = __bind(this.onkeyup, this);
      this.deactivate = __bind(this.deactivate, this);
      this.activate = __bind(this.activate, this);      this.mode = '';
      this.tableTags = ['td', 'th', 'table'];
      this.listTags = ['ul', 'ol', 'li'];
    }

    ContextManager.prototype.register = function(api) {
      this.api = api;
      this.$el = $(this.api.el);
      this.api.on("activate.editor", this.activate);
      return this.api.on("deactivate.editor", this.deactivate);
    };

    ContextManager.prototype.activate = function() {
      this.$el.on("keyup", this.onkeyup);
      return this.$el.on("mouseup", this.onmouseup);
    };

    ContextManager.prototype.deactivate = function() {
      this.$el.off("keyup", this.onkeyup);
      return this.$el.off("mouseup", this.onmouseup);
    };

    ContextManager.prototype.onkeyup = function(e) {
      var _ref;
      if (e.which === 13 || (33 <= (_ref = e.which) && _ref <= 40)) {
        return this.updateByRange();
      }
    };

    ContextManager.prototype.onmouseup = function(e) {
      return this.updateByRange();
    };

    ContextManager.prototype.updateByRange = function() {
      var el, range, tag;
      range = new Editor.Range(this.el, window);
      el = range.getParentElement(this.matchElement);
      if (!el) {
        this.updateMode('block', el);
        return;
      }
      tag = $(el).tagName();
      if ($.inArray(tag, this.tableTags) !== -1) {
        return this.updateMode('table', el);
      } else if ($.inArray(tag, this.listTags) !== -1) {
        return this.updateMode('list', el);
      } else {
        return this.updateMode('block', el);
      }
    };

    ContextManager.prototype.matchElement = function(el) {
      this.matchTags || (this.matchTags = this.tableTags.concat(this.listTags));
      return $.inArray($(el).tagName(), this.matchTags) !== -1;
    };

    ContextManager.prototype.isImage = function(el) {
      return el && $(el).tagName() === 'img';
    };

    ContextManager.prototype.updateMode = function(mode, target) {
      var modeTarget;
      modeTarget = this.getModeTarget(target);
      if (this.modeTarget !== modeTarget) {
        this.triggerHandler('hide' + capitalize(this.mode), target);
        this.triggerHandler('show' + capitalize(mode), target);
        this.modeTarget = modeTarget;
        this.mode = mode;
      }
      if (this.isImage(target)) return this.triggerHandler('selectImage', target);
    };

    ContextManager.prototype.getModeTarget = function(target) {
      var modeTarget;
      modeTarget = null;
      if (target) {
        if (this.isImage(target)) {
          modeTarget = target;
        } else if ($.inArray($(target).tagName(), this.tableTags) !== -1) {
          if ($(target).tagName() === 'table') {
            modeTarget = target;
          } else {
            modeTarget = $(target).parent('table');
          }
        }
      }
      return modeTarget;
    };

    return ContextManager;

  })();
  return ContextManager;
});

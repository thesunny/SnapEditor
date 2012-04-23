var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(["jquery.custom"], function($) {
  var Snap;
  Snap = (function() {

    function Snap() {
      this.tryCancel = __bind(this.tryCancel, this);
      this.setCancel = __bind(this.setCancel, this);
      this.update = __bind(this.update, this);
      this.unsnap = __bind(this.unsnap, this);
      this.snap = __bind(this.snap, this);
    }

    Snap.prototype.register = function(api) {
      this.api = api;
      this.$el = $(this.api.el);
      this.api.on("activate.editor", this.snap);
      return this.api.on("deactivate.editor", this.unsnap);
    };

    Snap.prototype.setup = function() {
      var div;
      div = $("<div/>").css({
        opacity: 0.2,
        position: 'absolute',
        background: 'black',
        top: 0,
        left: 0,
        zIndex: 100
      });
      div.on("mousedown", this.setCancel);
      div.on("mouseup", this.tryCancel);
      return this.divs = {
        top: div.clone(true, false).appendTo("body"),
        bottom: div.clone(true, false).appendTo("body"),
        left: div.clone(true, false).appendTo("body"),
        right: div.clone(true, false).appendTo("body")
      };
    };

    Snap.prototype.snap = function() {
      var div, options, position, _ref, _ref2, _ref3;
      if (!this.divs) this.setup();
      _ref = this.divs;
      for (position in _ref) {
        div = _ref[position];
        div.show();
      }
      options = this.getFxOptions();
      _ref2 = this.divs;
      for (position in _ref2) {
        div = _ref2[position];
        div.css(options.unsnapped[position]);
      }
      _ref3 = this.divs;
      for (position in _ref3) {
        div = _ref3[position];
        div.animate(options.snapped[position], {
          duration: "fast"
        });
      }
      this.$el.on("keyup mouseup", this.update);
      return $(window).on("resize", this.update);
    };

    Snap.prototype.unsnap = function() {
      var div, options, position, _ref, _ref2;
      if (this.divs) {
        options = this.getFxOptions();
        _ref = this.divs;
        for (position in _ref) {
          div = _ref[position];
          div.css(options.snapped[position]);
        }
        _ref2 = this.divs;
        for (position in _ref2) {
          div = _ref2[position];
          div.animate(options.unsnapped[position], {
            duration: "fast",
            complete: function() {
              return $(this).hide();
            }
          });
        }
        this.$el.off("keyup mouseup", this.update);
        return $(window).off("resize", this.update);
      }
    };

    Snap.prototype.getSnappedStyles = function(elCoords, documentSize) {
      return {
        top: {
          left: elCoords.left,
          width: elCoords.width,
          height: elCoords.top
        },
        bottom: {
          top: elCoords.bottom,
          left: elCoords.left,
          width: elCoords.width,
          height: documentSize.y - elCoords.bottom
        },
        left: {
          width: elCoords.left,
          height: documentSize.y
        },
        right: {
          left: elCoords.right,
          width: documentSize.x - elCoords.right,
          height: documentSize.y
        }
      };
    };

    Snap.prototype.getUnsnappedStyles = function(documentSize, portCoords) {
      return {
        top: {
          left: portCoords.left,
          width: portCoords.width,
          height: portCoords.top
        },
        bottom: {
          top: portCoords.bottom,
          left: portCoords.left,
          width: portCoords.width,
          height: documentSize.y - portCoords.bottom
        },
        left: {
          width: portCoords.left,
          height: documentSize.y
        },
        right: {
          left: portCoords.right,
          width: documentSize.x - portCoords.right,
          height: documentSize.y
        }
      };
    };

    Snap.prototype.getPortCoordinates = function() {
      var winScroll, winSize;
      winScroll = $(window).getScroll();
      winSize = $(window).getSize();
      return {
        top: winScroll.y,
        bottom: winScroll.y + winSize.y,
        left: winScroll.x,
        right: winScroll.x + winSize.x,
        width: winSize.x,
        height: winSize.y
      };
    };

    Snap.prototype.getFxOptions = function() {
      var documentSize, elCoords, portCoords;
      elCoords = this.$el.getCoordinates();
      documentSize = $(document).getSize();
      portCoords = this.getPortCoordinates();
      return {
        snapped: this.getSnappedStyles(elCoords, documentSize),
        unsnapped: this.getUnsnappedStyles(documentSize, portCoords)
      };
    };

    Snap.prototype.update = function() {
      var div, documentSize, elCoord, position, styles, _len, _ref, _results;
      elCoord = this.$el.getCoordinates();
      documentSize = $(document).getSize();
      styles = this.getSnappedStyles(elCoord, documentSize);
      _ref = this.divs;
      _results = [];
      for (div = 0, _len = _ref.length; div < _len; div++) {
        position = _ref[div];
        _results.push(div.css(styles[position]));
      }
      return _results;
    };

    Snap.prototype.setCancel = function() {
      return this.isCancel = true;
    };

    Snap.prototype.tryCancel = function() {
      if (this.isCancel) {
        this.isCancel = false;
        return this.api.deactivate();
      }
    };

    return Snap;

  })();
  return Snap;
});

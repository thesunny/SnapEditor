
define(["jquery.custom", "core/browser"], function($, Browser) {
  var Formizer;
  Formizer = (function() {

    function Formizer(el, toolbar) {
      this.$el = $(el);
      this.$toolbar = $(toolbar);
    }

    Formizer.prototype.call = function() {
      var elCoords, toolbarCoords;
      toolbarCoords = this.$toolbar.measure(function() {
        return this.getCoordinates();
      });
      elCoords = this.$el.getCoordinates();
      this.$div = $("<div/>").addClass("snapeditor-form-content").html(this.$el.html()).css({
        height: elCoords.height - toolbarCoords.height,
        overflowX: "auto",
        overflowY: Browser.isIE ? "scroll" : "auto"
      });
      this.$el.empty().append(this.$toolbar.show()).append(this.$div);
      return this.$el.addClass("snapeditor-form");
    };

    return Formizer;

  })();
  return Formizer;
});

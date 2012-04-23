
define(["jquery.custom", "core/browser"], function($, Browser) {
  var Formizer;
  Formizer = (function() {

    function Formizer(el) {
      this.$el = $(el);
      this.$content = $("<div/>").addClass("snapeditor-form-content");
    }

    Formizer.prototype.formize = function(toolbar) {
      var $toolbar, elCoords, toolbarCoords;
      $toolbar = $(toolbar);
      toolbarCoords = $toolbar.measure(function() {
        return this.getCoordinates();
      });
      elCoords = this.$el.getCoordinates();
      this.$content.html(this.$el.html()).css({
        height: elCoords.height - toolbarCoords.height,
        overflowX: "auto",
        overflowY: Browser.isIE ? "scroll" : "auto"
      });
      this.$el.empty().append($toolbar.show()).append(this.$content);
      return this.$el.addClass("snapeditor-form");
    };

    return Formizer;

  })();
  return Formizer;
});

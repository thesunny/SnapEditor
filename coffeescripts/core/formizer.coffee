define ["jquery.custom", "core/browser"], ($, Browser) ->
  class Formizer
    constructor: (el) ->
      @$el = $(el)
      @$content = $("<div/>").addClass("snapeditor_form_content").
        html(@$el.html()).hide().appendTo("body")

    formize: (toolbar) ->
      $toolbar = $(toolbar)
      toolbarCoords = $toolbar.measure(-> @getCoordinates())
      elCoords = @$el.getCoordinates()
      @$content.css(
          height: elCoords.height - toolbarCoords.height
          overflowX: "auto"
          overflowY: if Browser.isIE then "scroll" else "auto"
        )
      @$el.empty().append($toolbar.show()).append(@$content.show())
      @$el.addClass("snapeditor_form")

  return Formizer

define ["jquery.custom", "core/browser"], ($, Browser) ->
  class Formizer
    constructor: (el) ->
      @$el = $(el)
      @$content = $("<div/>").addClass("snapeditor-form-content")

    formize: (toolbar) ->
      $toolbar = $(toolbar)
      toolbarCoords = $toolbar.measure(-> @getCoordinates())
      elCoords = @$el.getCoordinates()
      @$content.html(@$el.html()).
        css(
          height: elCoords.height - toolbarCoords.height
          overflowX: "auto"
          overflowY: if Browser.isIE then "scroll" else "auto"
        )
      @$el.empty().append($toolbar.show()).append(@$content)
      @$el.addClass("snapeditor-form")

  return Formizer

define ["cs!jquery.custom", "cs!core/browser"], ($, Browser) ->
  class Formizer
    constructor: (el, toolbar) ->
      @$el = $(el)
      @$toolbar = $(toolbar)

    call: ->
      toolbarCoords = @$toolbar.measure(-> @getCoordinates())
      elCoords = @$el.getCoordinates()
      @$div = $("<div/>").addClass("snapeditor-form-content").
        html(@$el.html()).
        css(
          height: elCoords.height - toolbarCoords.height
          overflowX: "auto"
          overflowY: if Browser.isIE then "scroll" else "auto"
        )
      @$el.empty().append(@$toolbar.show()).append(@$div)
      @$el.addClass("snapeditor-form")

  return Formizer

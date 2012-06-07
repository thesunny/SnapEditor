define ["jquery.custom"], ($) ->
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
          overflowY: "scroll"
        )
      @$el.empty().append($toolbar.show()).append(@$content.show())
      @$el.addClass("snapeditor_form")

  return Formizer

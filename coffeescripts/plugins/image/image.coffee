define ["jquery.custom"], ($) ->
  class Image
    register: (@api) ->
      @api.on("snapeditor.activate", @activate)
      @api.on("snapeditor.deactivate", @deactivate)

    activate: =>
      $(@api.el).on("mousedown", @mousedown)

    deactivate: =>
      $(@api.el).off("mousedown", @mousedown)

    mousedown: (e) =>
      $el = $(e.target)
      # Webkit fails to actually select the image when clicking on it. Hence,
      # we manually select it. This does not break other browsers so it is left
      # in for consistency.
      @api.select($el[0]) if $el.tagName() == "img"

  return Image

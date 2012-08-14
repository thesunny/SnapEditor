# NOTE: We can't use CoffeeScript's => (fat arrow) to define the mousedown and
# mouseup functions because it sets "this" to the window, not the object. This
# happens because we aren't defining a class.
define ["jquery.custom"], ($) ->
  return {
    # IE requires contentEditable to be set after a mouseup in order to
    # preserve cursor position. At this point, a range will exist.
    addActivateEvents: ->
      $(@api.el).one("mouseup", => @onmouseup.apply(this, arguments))

    onmouseup: (e) ->
      target = e.target
      unless @isLink(target)
        isImage = $(target).tagName() == "img"
        # TODO: This no longer seems to apply. Commenting out for now along
        # with the "else" statement below. Remove this once we're sure we
        # don't need it.
        # NOTE: In IE, we need to save the range prior to turning on
        # contentEditable and then selecting it after contentEditable. This
        # allows the selection to keep after the editor has been turned on.
        #range = @api.range() unless isImage

        @click()

        # NOTE: When selecting an image to snap edit in IE, the new Range
        # created is not a controlRange that represents the image. It is a
        # brand new textRange at the top of the editor. For some reason, the
        # image is not yet selected. Hence, if we reselect the range, it makes
        # the window jump to the top of the editor. To fix this, if the target
        # was an image, we select it directly rather than reselecting the old
        # range.
        if isImage
          # TODO: Once the API is figured out, revisit @api.select(...)
          @api.select(target)
        #else
          #range.select()

        @activate()
  }

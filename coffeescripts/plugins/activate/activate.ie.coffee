define ["jquery.custom"], ($) ->
  return {
    # IE requires contentEditable to be set after a mouseup in order to
    # preserve cursor position. At this point, a range will exist.
    addActivateEvents: (api) ->
      # Add the events directly to the element instead of using SnapEditor
      # events because the Activate plugin is the one that starts off the
      # SnapEditor events.
      self = this
      $(api.el).one("mouseup", (e) -> self.onmouseup(e, api))

    onmouseup: (e, api) ->
      target = e.target
      unless @isLink(target)
        isImage = $(target).tagName() == "img"
        @click(api)
        # NOTE: When selecting an image to snap edit in IE, the new Range
        # created is not a controlRange that represents the image. It is a
        # brand new textRange at the top of the editor. For some reason, the
        # image is not yet selected. Hence, if we reselect the range, it makes
        # the window jump to the top of the editor. To fix this, if the target
        # was an image, we select it directly rather than reselecting the old
        # range.
        api.select(target) if isImage
        @activate(api)
  }

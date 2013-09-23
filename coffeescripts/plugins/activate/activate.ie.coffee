# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom"], ($) ->
  return {
    # IE requires contentEditable to be set after a mouseup in order to
    # preserve cursor position. At this point, a range will exist.
    addActivateEvents: (api) ->
      # Add the events directly to the element instead of using SnapEditor
      # events because the Activate plugin is the one that starts off the
      # SnapEditor events.
      self = this
      $(api.el).one("click", (e) -> self.click(e, api))
      $(api.el).one("mouseup", (e) -> self.onmouseup(e, api))

    onmouseup: (e, api) ->
      target = e.target
      if @shouldActivate(api, target)
        isImage = $(target).tagName() == "img"
        # NOTE: This should trigger making @api.$el editable.
        api.trigger("snapeditor.activate_click")
        # NOTE: When selecting an image to snap edit in IE, the new Range
        # created is not a controlRange that represents the image. It is a
        # brand new textRange at the top of the editor. For some reason, the
        # image is not yet selected. Hence, if we reselect the range, it makes
        # the window jump to the top of the editor. To fix this, if the target
        # was an image, we select it directly rather than reselecting the old
        # range.
        api.select(target) if isImage
        if @isLink(target)
          # We select the target then collapse to the end because if we use
          # api.selectEndOfElement(), in IE10, the iframe jumps to the
          # beginning of the content even when the cursor is properly placed
          # at the end of the link.
          api.select(target)
          api.collapse(false)
        @finishActivate(api)
      else
        self = this
        $(api.el).one("mouseup", (e) -> self.onmouseup(e, api))
  }

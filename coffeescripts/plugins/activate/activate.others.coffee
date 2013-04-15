define ["jquery.custom"], ($) ->
  return {
    # W3C requires contentEditable to be set after a mousedown in order to
    # preserve cusor position. However, at this point, a range does not exist.
    # It exists after a click or mouseup.
    addActivateEvents: (api) ->
      # Add the events directly to the element instead of using SnapEditor
      # events because the Activate plugin is the one that starts off the
      # SnapEditor events.
      self = this
      $(api.el).one("mousedown", (e) -> self.onmousedown(e, api))
      $(api.el).one("mouseup", (e) -> self.onmouseup(e, api))

    onmousedown: (e, api) ->
      @click(api) unless @isLink(e.target)

    onmouseup: (e, api) ->
      target = e.target
      unless @isLink(target)
        # NOTE: Clicking on an image to activate the editor for the very first
        # time causes some problems. In Webkit, it does not create a range
        # immediately. Not even after a mouseup. If we delay for 100ms, then
        # the range is created. I tried delaying for 10ms, but it still wasn't
        # available. Adding a delay felt very hacky and would depend on the
        # speed of the user's browser. Instead, if the target is an image, we
        # manually select it first to avoid the range problem.
        #
        # NOTE: In Gecko, there are no problems. However, there is no harm in
        # leaving it in. We leave it in for Gecko for consistency.
        #
        api.select(target) if $(target).tagName() == 'img'
        @activate(api)
  }

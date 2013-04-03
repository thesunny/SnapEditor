define ["jquery.custom"], ($) ->
  return {
    # W3C requires contentEditable to be set after a mousedown in order to
    # preserve cusor position. However, at this point, a range does not exist.
    # It exists after a click or mouseup.
    addActivateEvents: (api) ->
      # Add the events directly to the element instead of using SnapEditor
      # events because the Activate plugin is the one that starts off the
      # SnapEditor events.
      data = api: api
      $(api.el).one("mousedown", data, @onmousedown)
      $(api.el).one("mouseup", data, @onmouseup)

    onmousedown: (e) ->
      api = e.data.api
      plugin = api.config.plugins.activate
      plugin.click(api) unless plugin.isLink(e.target)

    onmouseup: (e) ->
      target = e.target
      api = e.data.api
      plugin = api.config.plugins.activate
      unless plugin.isLink(target)
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
        plugin.activate(api)
  }

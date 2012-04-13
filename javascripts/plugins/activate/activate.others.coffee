# NOTE: We can't use CoffeeScript's => (fat arrow) to define the mousedown and
# mouseup functions because it sets "this" to the window, not the object. This
# happens because we aren't defining a class.
define ["cs!jquery.custom"], ($) ->
  return {
    # W3C requires contentEditable to be set after a mousedown in order to
    # preserve cusor position. However, at this point, a range does not exist.
    # It exists after a click or mouseup.
    addActivateEvents: ->
      $(@api.el).one("mousedown", => @onmousedown.apply(this, arguments))
      $(@api.el).one("mouseup", => @onmouseup.apply(this, arguments))

    onmousedown: (e) ->
      @click() unless @isLink(e.target)

    onmouseup: (e) ->
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
        # TODO: Once the API is figured out, revisit @api.select(...)
        @api.select(target) if $(target).tagName() == 'img'
        @activate()
  }

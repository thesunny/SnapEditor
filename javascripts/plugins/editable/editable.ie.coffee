define ["cs!jquery.custom", "cs!core/range"], ($, Range) ->
  return {
    start: ->
      $(@api.el).attr("contentEditable", true)
      # IE includes annoying image resize handlers that cannot be removed.
      # Instead, we prevent any resizing from happening by preventing the
      # event.
      #
      # NOTE: The event handler must be attached and detached using native
      # JavaScript or it will not work.
      @api.el.attachEvent("onresizestart", @preventResize)

    finishBrowser: () ->
      @api.el.detachEvent("onresizestart", @preventResize)

    preventResize: (e) ->
      e.returnValue = false
  }

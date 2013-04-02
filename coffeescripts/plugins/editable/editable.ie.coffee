define ["core/range"], (Range) ->
  return {
    start: (api) ->
      api.el.contentEditable = true
      # IE includes annoying image resize handlers that cannot be removed.
      # Instead, we prevent any resizing from happening by preventing the
      # event.
      #
      # NOTE: The event handler must be attached and detached using native
      # JavaScript or it will not work.
      api.el.attachEvent("onresizestart", api.config.plugins.editable.preventResize)

    deactivateBrowser: (api) ->
      api.el.detachEvent("onresizestart", api.config.plugins.editable.preventResize)

    preventResize: (e) ->
      e.returnValue = false
  }

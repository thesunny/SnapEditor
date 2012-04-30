define ["config/config.default", "plugins/snap/snap", "plugins/autoscroll/autoscroll"], (Defaults, Snap, Autoscroll) ->
  return {
    build: ->
      defaults = Defaults.build()
      return {
        plugins: defaults.plugins.concat([new Snap(), new Autoscroll()])
        toolbar: defaults.toolbar
      }
  }

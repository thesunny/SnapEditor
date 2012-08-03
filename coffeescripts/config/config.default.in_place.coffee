define ["config/config.default", "plugins/snap/snap", "plugins/outline/outline", "plugins/autoscroll/autoscroll"], (Defaults, Snap, Outline, Autoscroll) ->
  return {
    build: ->
      defaults = Defaults.build()
      return {
        plugins: defaults.plugins.concat([new Snap(), new Outline(), new Autoscroll()])
        toolbar: defaults.toolbar
        whitelist: defaults.whitelist
      }
  }

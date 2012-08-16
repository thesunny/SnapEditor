define ["config/config.default", "plugins/snap/snap", "plugins/outline/outline"], (Defaults, Snap, Outline) ->
  return {
    build: ->
      defaults = Defaults.build()
      return {
        plugins: defaults.plugins.concat([new Snap(), new Outline()])
        toolbar: defaults.toolbar
        whitelist: defaults.whitelist
      }
  }

define [
  "config/config.default"
  "plugins/snap/snap"
  "plugins/outline/outline"
  "plugins/save/save"
], (Defaults, Snap, Outline, Save) ->
  return {
    build: ->
      defaults = Defaults.build()
      defaults.plugins = defaults.plugins.concat([
        new Snap()
        new Outline()
        new Save()
      ])
      defaults.toolbar = defaults.toolbar.concat(["|", "SaveCancel"])
      return defaults
  }

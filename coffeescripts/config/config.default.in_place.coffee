define [
  "config/config.default"
  "plugins/snap/snap"
  "plugins/outline/outline"
  "plugins/save/save"
], (Defaults, Snap, Outline, Save) ->
  SnapEditor.InPlace.config = $.extend(
    snap: true
    SnapEditor.config
  )
  SnapEditor.InPlace.config.behaviours = SnapEditor.InPlace.config.behaviours.concat([
    "snap"
    "outline"
  ])

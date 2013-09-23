# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define [
  "jquery.custom"
  "config/config.default"
  "plugins/snap/snap"
  "plugins/outline/outline"
  "plugins/save/save"
], ($, Defaults, Snap, Outline, Save) ->
  SnapEditor.InPlace.config = $.extend(
    snap: true
    SnapEditor.config
  )
  SnapEditor.InPlace.config.behaviours = SnapEditor.InPlace.config.behaviours.concat([
    "snap"
    "outline"
  ])

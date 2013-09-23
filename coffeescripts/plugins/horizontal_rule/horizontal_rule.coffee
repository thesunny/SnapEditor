# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  SnapEditor.actions.horizontalRule = (e) -> e.api.clean() if e.api.insertHorizontalRule()

  SnapEditor.buttons.horizontalRule = Helpers.createButton("horizontalRule", "ctrl+=", onInclude: (e) -> e.api.addWhitelistRule("HR", "hr"))
  SnapEditor.insertStyles("plugins_horizontal_rule", Helpers.createStyles("horizontalRule", 24 * -26))

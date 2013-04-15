define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  SnapEditor.commands.horizontalRule = Helpers.createCommand("horizontalRule", "ctrl+=", (e) ->
    e.api.clean() if e.api.insertHorizontalRule()
  )
  SnapEditor.insertStyles("plugins_horizontal_rule", Helpers.createStyles("horizontalRule", 24 * -26))

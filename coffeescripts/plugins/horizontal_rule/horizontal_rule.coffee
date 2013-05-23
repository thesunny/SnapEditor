define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  SnapEditor.actions.horizontalRule = (e) -> e.api.clean() if e.api.insertHorizontalRule()

  SnapEditor.buttons.horizontalRule = Helpers.createButton("horizontalRule", "ctrl+=")
  SnapEditor.insertStyles("plugins_horizontal_rule", Helpers.createStyles("horizontalRule", 24 * -26))

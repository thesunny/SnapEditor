define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  SnapEditor.buttons.horizontalRule = Helpers.createButton("horizontalRule", "ctrl+=", (e) ->
    e.api.clean() if e.api.insertHorizontalRule()
  )
  SnapEditor.insertStyles("plugins_horizontal_rule", Helpers.createStyles("horizontalRule", 24 * -26))

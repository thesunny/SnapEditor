define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  window.SnapEditor.internalPlugins.inline =
    commands:
      bold: Helpers.createCommand("bold", "ctrl.b", (e) -> e.api.config.plugins.inline.format(e))
      italic: Helpers.createCommand("italic", "ctrl.i", (e) -> e.api.config.plugins.inline.format(e))
      underline: Helpers.createCommand("underline", "ctr.u", (e) -> e.api.config.plugins.inline.format(e))
      subscript: Helpers.createCommand("subscript", "ctrl.shift.-", (e) -> e.api.config.plugins.inline.format(e))
      superscript: Helpers.createCommand("superscript", "ctrl.shift.=", (e) -> e.api.config.plugins.inline.format(e))
      strikethrough: Helpers.createCommand("strikethrough", "ctrl.-", (e) -> e.api.config.plugins.inline.format(e))
    format: (e) -> e.api.clean() if e.api.formatInline(e.type)

  styles = ""
  for command, i in ["bold", "italic", "underline", "subscript", "superscript", "strikethrough"]
    styles += Helpers.createStyles(command, i * -26) # sprite position * step
  window.SnapEditor.insertStyles("plugins_inline", styles)

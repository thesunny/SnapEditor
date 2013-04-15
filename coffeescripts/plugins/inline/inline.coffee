define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  format = (e) -> e.api.clean() if e.api.formatInline(e.type)
  $.extend(SnapEditor.commands,
    bold: Helpers.createCommand("bold", "ctrl+b", format)
    italic: Helpers.createCommand("italic", "ctrl+i", format)
    underline: Helpers.createCommand("underline", "ctrl+u", format)
    subscript: Helpers.createCommand("subscript", "ctrl+shift+-", format)
    superscript: Helpers.createCommand("superscript", "ctrl+shift+=", format)
    strikethrough: Helpers.createCommand("strikethrough", "ctrl+-", format)
  )

  styles = ""
  for command, i in ["bold", "italic", "underline", "subscript", "superscript", "strikethrough"]
    styles += Helpers.createStyles(command, i * -26) # sprite position * step
  SnapEditor.insertStyles("plugins_inline", styles)

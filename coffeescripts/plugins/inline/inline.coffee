define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  format = (e) -> e.api.clean() if e.api.formatInline(e.type)
  $.extend(SnapEditor.buttons,
    bold: Helpers.createButton("bold", "ctrl+b", format)
    italic: Helpers.createButton("italic", "ctrl+i", format)
    underline: Helpers.createButton("underline", "ctrl+u", format)
    subscript: Helpers.createButton("subscript", "ctrl+shift+-", format)
    superscript: Helpers.createButton("superscript", "ctrl+shift+=", format)
    strikethrough: Helpers.createButton("strikethrough", "ctrl+-", format)
  )

  styles = ""
  for button, i in ["bold", "italic", "underline", "subscript", "superscript", "strikethrough"]
    styles += Helpers.createStyles(button, i * -26) # sprite position * step
  SnapEditor.insertStyles("plugins_inline", styles)

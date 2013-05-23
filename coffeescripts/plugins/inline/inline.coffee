define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  formatInline = (e) -> e.api.clean() if e.api.formatInline(e.type)
  SnapEditor.actions.bold = formatInline
  SnapEditor.actions.italic = formatInline
  SnapEditor.actions.underline = formatInline
  SnapEditor.actions.subscript = formatInline
  SnapEditor.actions.superscript = formatInline
  SnapEditor.actions.strikethrough = formatInline

  $.extend(SnapEditor.buttons,
    bold: Helpers.createButton("bold", "ctrl+b")
    italic: Helpers.createButton("italic", "ctrl+i")
    underline: Helpers.createButton("underline", "ctrl+u")
    subscript: Helpers.createButton("subscript", "ctrl+shift+-")
    superscript: Helpers.createButton("superscript", "ctrl+shift+=")
    strikethrough: Helpers.createButton("strikethrough", "ctrl+-")
  )

  styles = ""
  for button, i in ["bold", "italic", "underline", "subscript", "superscript", "strikethrough"]
    styles += Helpers.createStyles(button, i * -26) # sprite position * step
  SnapEditor.insertStyles("plugins_inline", styles)

define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  align = (e) -> e.api.clean() if e.api.align(e.type.replace(/align/, "").toLowerCase())
  $.extend(SnapEditor.buttons,
    alignment:
      text: SnapEditor.lang.alignment
      items: ["alignLeft", "alignCentre", "alignRight", "alignJustify"]
    alignLeft: Helpers.createButton("alignLeft", "ctrl+l", align)
    alignCentre: Helpers.createButton("alignCentre", "ctrl+e", align)
    alignRight: Helpers.createButton("alignRight", "ctrl+r", align)
    alignJustify: Helpers.createButton("alignJustify", "ctrl+j", align)
  )

  styles = "div.snapeditor_toolbar_menu_alignment { width: 220px; }"
  styles += Helpers.createStyles("alignment", 28 * -26 )
  for button, i in ["alignLeft", "alignCentre", "alignRight", "alignJustify"]
    styles += Helpers.createStyles(button, (13 + i) * -26) # sprite position * step
  SnapEditor.insertStyles("plugins_align", styles)

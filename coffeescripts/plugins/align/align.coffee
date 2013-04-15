define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  align = (e) -> e.api.clean() if e.api.align(e.type.replace(/align/, "").toLowerCase())
  $.extend(SnapEditor.commands,
    alignment:
      text: SnapEditor.lang.alignment
      items: ["alignLeft", "alignCentre", "alignRight", "alignJustify"]
    alignLeft: Helpers.createCommand("alignLeft", "ctrl+l", align)
    alignCentre: Helpers.createCommand("alignCentre", "ctrl+e", align)
    alignRight: Helpers.createCommand("alignRight", "ctrl+r", align)
    alignJustify: Helpers.createCommand("alignJustify", "ctrl+j", align)
  )

  styles = "div.snapeditor_toolbar_menu_alignment { width: 220px; }"
  styles += Helpers.createStyles("alignment", 28 * -26 )
  for command, i in ["alignLeft", "alignCentre", "alignRight", "alignJustify"]
    styles += Helpers.createStyles(command, (13 + i) * -26) # sprite position * step
  SnapEditor.insertStyles("plugins_align", styles)

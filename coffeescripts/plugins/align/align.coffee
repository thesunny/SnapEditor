define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  align = (e) -> e.api.clean() if e.api.align(e.type.replace(/align/, "").toLowerCase())
  SnapEditor.actions.alignLeft = align
  SnapEditor.actions.alignCentre = align
  SnapEditor.actions.alignRight = align
  SnapEditor.actions.alignJustify = align

  $.extend(SnapEditor.buttons,
    alignment:
      text: SnapEditor.lang.alignment
      items: ["alignLeft", "alignCentre", "alignRight", "alignJustify"]
    alignLeft: Helpers.createButton("alignLeft", "ctrl+l")
    alignCentre: Helpers.createButton("alignCentre", "ctrl+e")
    alignRight: Helpers.createButton("alignRight", "ctrl+r")
    alignJustify: Helpers.createButton("alignJustify", "ctrl+j")
  )

  styles = "div.snapeditor_toolbar_menu_alignment { width: 220px; }"
  styles += Helpers.createStyles("alignment", 28 * -26 )
  for button, i in ["alignLeft", "alignCentre", "alignRight", "alignJustify"]
    styles += Helpers.createStyles(button, (13 + i) * -26) # sprite position * step
  SnapEditor.insertStyles("plugins_align", styles)

define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  window.SnapEditor.internalPlugins.align =
    commands:
      alignment:
        text: window.SnapEditor.lang.alignment
        items: ["alignLeft", "alignCentre", "alignRight", "alignJustify"]
      alignLeft: Helpers.createCommand("alignLeft", "ctrl.l", (e) -> e.api.plugins.align.align(e))
      alignCentre: Helpers.createCommand("alignCentre", "ctrl.e", (e) -> e.api.plugins.align.align(e))
      alignRight: Helpers.createCommand("alignRight", "ctrl.r", (e) -> e.api.plugins.align.align(e))
      alignJustify: Helpers.createCommand("alignJustify", "ctrl.j", (e) -> e.api.plugins.align.align(e))
    align: (e) -> e.api.clean() if e.api.align(e.type.replace(/align/, "").toLowerCase())

  styles = "
    div.snapeditor_toolbar_menu_alignment { width: 210px; }
  "
  styles += Helpers.createStyles("alignment", 28 * -26 )
  for command, i in ["alignLeft", "alignCentre", "alignRight", "alignJustify"]
    styles += Helpers.createStyles(command, (13 + i) * -26) # sprite position * step
  window.SnapEditor.insertStyles("plugins_align", styles)

# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
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
    alignLeft: Helpers.createButton("alignLeft", "ctrl+l", onInclude: (e) ->
      e.api.addWhitelistGeneralRule("[style=(text-align)]", ["div", "p", "h1", "h2", "h3", "h4", "h5", "h6", "th", "td"]))
    alignCentre: Helpers.createButton("alignCentre", "ctrl+e", onInclude: (e) ->
      e.api.addWhitelistGeneralRule("[style=(text-align)]", ["div", "p", "h1", "h2", "h3", "h4", "h5", "h6", "th", "td"]))
    alignRight: Helpers.createButton("alignRight", "ctrl+r", onInclude: (e) ->
      e.api.addWhitelistGeneralRule("[style=(text-align)]", ["div", "p", "h1", "h2", "h3", "h4", "h5", "h6", "th", "td"]))
    alignJustify: Helpers.createButton("alignJustify", "ctrl+j", onInclude: (e) ->
      e.api.addWhitelistGeneralRule("[style=(text-align)]", ["div", "p", "h1", "h2", "h3", "h4", "h5", "h6", "th", "td"]))
  )

  styles = "div.snapeditor_toolbar_menu_alignment { width: 220px; }"
  styles += Helpers.createStyles("alignment", 28 * -26 )
  for button, i in ["alignLeft", "alignCentre", "alignRight", "alignJustify"]
    styles += Helpers.createStyles(button, (13 + i) * -26) # sprite position * step
  SnapEditor.insertStyles("plugins_align", styles)

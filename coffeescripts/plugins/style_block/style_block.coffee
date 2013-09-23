# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  getHTML = (i) -> "<span class=\"snapeditor_style_block_h#{i}\">#{SnapEditor.lang["h#{i}"]}</span>"
  SnapEditor.addStyleButtons(
    p: text: SnapEditor.lang.p, shortcut: "ctrl+alt+0"
    h1: text: SnapEditor.lang.h1, html: getHTML(1), shortcut: "ctrl+alt+1"
    h2: text: SnapEditor.lang.h2, html: getHTML(2), shortcut: "ctrl+alt+2"
    h3: text: SnapEditor.lang.h3, html: getHTML(3), shortcut: "ctrl+alt+3"
    h4: text: SnapEditor.lang.h4, html: getHTML(4), shortcut: "ctrl+alt+4"
    h5: text: SnapEditor.lang.h5, html: getHTML(5), shortcut: "ctrl+alt+5"
    h6: text: SnapEditor.lang.h6, html: getHTML(6), shortcut: "ctrl+alt+6"
  )
  SnapEditor.addStyleList("styleBlock", SnapEditor.lang.styleBlock, "style-block")
  # Create aliases for style buttons.
  for button, i in ["p", "h1", "h2", "h3", "h4", "h5", "h6"]
    SnapEditor.buttons[button] = SnapEditor.buttons[SnapEditor.getStyleKey(button)]

  styles = """
    div.snapeditor_toolbar_menu_style_block { width: 275px; }
    .snapeditor_style_block_h1 { margin: 0; padding: 0; font-size: 200%; }
    .snapeditor_style_block_h2 { margin: 0; padding: 0; font-size: 180%; }
    .snapeditor_style_block_h3 { margin: 0; padding: 0; font-size: 160%; }
    .snapeditor_style_block_h4 { margin: 0; padding: 0; font-size: 140%; }
    .snapeditor_style_block_h5 { margin: 0; padding: 0; font-size: 120%; }
    .snapeditor_style_block_h6 { margin: 0; padding: 0; font-size: 110%; }
  """ + Helpers.createStyles("styleBlock", 29 * -26)
  for button, i in ["p", "h1", "h2", "h3", "h4", "h5", "h6"]
    styles += Helpers.createStyles(button, (i + 6) * -26) # sprite position * step
  SnapEditor.insertStyles("plugins_style_block", styles)

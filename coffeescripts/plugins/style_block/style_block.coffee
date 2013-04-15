define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  getHTML = (i) -> "<span class=\"snapeditor_style_block_h#{i}\">#{SnapEditor.lang["h#{i}"]}</span>"
  format = (e) -> e.api.clean() if e.api.formatBlock(e.type)
  $.extend(SnapEditor.buttons,
    styleBlock:
      text: SnapEditor.lang.styleBlock
      items: ["p", "h1", "h2", "h3", "h4", "h5", "h6"]
    p: Helpers.createButton("p", "ctrl+alt+0", format)
    h1: Helpers.createButton("h1", "ctrl+alt+1", format, html: getHTML(1))
    h2: Helpers.createButton("h2", "ctrl+alt+2", format, html: getHTML(2))
    h3: Helpers.createButton("h3", "ctrl+alt+3", format, html: getHTML(3))
    h4: Helpers.createButton("h4", "ctrl+alt+4", format, html: getHTML(4))
    h5: Helpers.createButton("h5", "ctrl+alt+5", format, html: getHTML(5))
    h6: Helpers.createButton("h6", "ctrl+alt+6", format, html: getHTML(6))
  )

  styles = """
    div.snapeditor_toolbar_menu_style_block { width: 275px; }
    .snapeditor_style_block_h1 { margin: 0; padding: 0; font-size: 200%; }
    .snapeditor_style_block_h2 { margin: 0; padding: 0; font-size: 180%; }
    .snapeditor_style_block_h3 { margin: 0; padding: 0; font-size: 160%; }
    .snapeditor_style_block_h4 { margin: 0; padding: 0; font-size: 140%; }
    .snapeditor_style_block_h5 { margin: 0; padding: 0; font-size: 120%; }
    .snapeditor_style_block_h6 { margin: 0; padding: 0; font-size: 110%; }
  """ + Helpers.createStyles("styleBlock", 6 * -26)
  SnapEditor.insertStyles("plugins_style_block", styles)

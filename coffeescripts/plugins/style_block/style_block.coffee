define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  format = (e) -> e.api.clean() if e.api.styleBlock(e.type)
  SnapEditor.actions.p = format
  SnapEditor.actions.h1 = format
  SnapEditor.actions.h2 = format
  SnapEditor.actions.h3 = format
  SnapEditor.actions.h4 = format
  SnapEditor.actions.h5 = format
  SnapEditor.actions.h6 = format

  getHTML = (i) -> "<span class=\"snapeditor_style_block_h#{i}\">#{SnapEditor.lang["h#{i}"]}</span>"
  $.extend(SnapEditor.buttons,
    styleBlock:
      text: SnapEditor.lang.styleBlock
      items: ["p", "h1", "h2", "h3", "h4", "h5", "h6"]
    p: Helpers.createButton("p", "ctrl+alt+0")
    h1: Helpers.createButton("h1", "ctrl+alt+1", html: getHTML(1))
    h2: Helpers.createButton("h2", "ctrl+alt+2", html: getHTML(2))
    h3: Helpers.createButton("h3", "ctrl+alt+3", html: getHTML(3))
    h4: Helpers.createButton("h4", "ctrl+alt+4", html: getHTML(4))
    h5: Helpers.createButton("h5", "ctrl+alt+5", html: getHTML(5))
    h6: Helpers.createButton("h6", "ctrl+alt+6", html: getHTML(6))
  )

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

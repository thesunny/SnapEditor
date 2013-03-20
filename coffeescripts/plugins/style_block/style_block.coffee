define ["jquery.custom", "plugins/helpers"], ($, Helpers) ->
  actionHandler = (e) -> e.api.config.plugins.styleBlock.format(e)
  window.SnapEditor.internalPlugins.styleBlock =
    commands:
      styleBlock:
        text: window.SnapEditor.lang.styleBlock
        items: ["p", "h1", "h2", "h3", "h4", "h5", "h6"]
      p: Helpers.createCommand("p", "ctrl.alt.0", actionHandler)
      h1: Helpers.createCommand("h1", "ctrl.alt.1", actionHandler, html: "<span class=\"snapeditor_style_block_h1\">#{window.SnapEditor.lang.h1}</span>")
      h2: Helpers.createCommand("h2", "ctrl.alt.2", actionHandler, html: "<span class=\"snapeditor_style_block_h2\">#{window.SnapEditor.lang.h2}</span>")
      h3: Helpers.createCommand("h3", "ctrl.alt.3", actionHandler, html: "<span class=\"snapeditor_style_block_h3\">#{window.SnapEditor.lang.h3}</span>")
      h4: Helpers.createCommand("h4", "ctrl.alt.4", actionHandler, html: "<span class=\"snapeditor_style_block_h4\">#{window.SnapEditor.lang.h4}</span>")
      h5: Helpers.createCommand("h5", "ctrl.alt.5", actionHandler, html: "<span class=\"snapeditor_style_block_h5\">#{window.SnapEditor.lang.h5}</span>")
      h6: Helpers.createCommand("h6", "ctrl.alt.6", actionHandler, html: "<span class=\"snapeditor_style_block_h6\">#{window.SnapEditor.lang.h6}</span>")
    format: (e) -> e.api.clean() if e.api.formatBlock(e.type)

  styles = """
    div.snapeditor_toolbar_menu_style_block { width: 250px;}
    .snapeditor_style_block_h1 { margin: 0; padding: 0; font-size: 200%; }
    .snapeditor_style_block_h2 { margin: 0; padding: 0; font-size: 180%; }
    .snapeditor_style_block_h3 { margin: 0; padding: 0; font-size: 160%; }
    .snapeditor_style_block_h4 { margin: 0; padding: 0; font-size: 140%; }
    .snapeditor_style_block_h5 { margin: 0; padding: 0; font-size: 120%; }
    .snapeditor_style_block_h6 { margin: 0; padding: 0; font-size: 110%; }
  """ + Helpers.createStyles("styleBlock", 6 * -26)
  window.SnapEditor.insertStyles("plugins_style_block", styles)

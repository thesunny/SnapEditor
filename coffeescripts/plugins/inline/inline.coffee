define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  class InlineStyler
    register: (@api) ->

    getUI: (ui) ->
      bold = ui.button(action: "bold", description: @api.lang.bold, shortcut: "Ctrl+B", icon: { url: @api.assets.image("text_bold.png"), width: 24, height: 24, offset: [3, 3] })
      italic = ui.button(action: "italic", description: @api.lang.italic, shortcut: "Ctrl+I", icon: { url: @api.assets.image("text_italic.png"), width: 24, height: 24, offset: [3, 3] })
      underline = ui.button(action: "underline", description: @api.lang.underline, shortcut: "Ctrl+U", icon: { url: @api.assets.image("text_underline.png"), width: 24, height: 24, offset: [3, 3] })
      subscript = ui.button(action: "subscript", description: @api.lang.subscript, shortcut: "Ctrl+Shift+-", icon: { url: @api.assets.image("text_subscript.png"), width: 24, height: 24, offset: [3, 3] })
      superscript = ui.button(action: "superscript", description: @api.lang.superscript, shortcut: "Ctrl+Shift+=", icon: { url: @api.assets.image("text_superscript.png"), width: 24, height: 24, offset: [3, 3] })
      strikethrough = ui.button(action: "strikethrough", description: @api.lang.strikethrough, shortcut: "Ctrl+-", icon: { url: @api.assets.image("text_strikethrough.png"), width: 24, height: 24, offset: [3, 3] })
      return {
        "toolbar:default": "inline"
        inline: [bold, italic]
        bold: bold
        italic: italic
        underline: underline
        subscript: subscript
        superscript: superscript
        strikethrough: strikethrough
      }

    getActions: ->
      return {
        bold: Helpers.pass(@format, "bold")
        italic: Helpers.pass(@format, "italic")
        underline: Helpers.pass(@format, "underline")
        subscript: Helpers.pass(@format, "subscript")
        superscript: Helpers.pass(@format, "superscript")
        strikethrough: Helpers.pass(@format, "strikethrough")
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.b": "bold"
        "ctrl.i": "italic"
        "ctrl.u": "underline"
        "ctrl.shift.-": "subscript"
        "ctrl.shift.=": "superscript"
        "ctrl.-": "strikethrough"
      }

    format: (type) =>
      @update() if @api.formatInline(type)

    update: ->
      # In Webkit, after the toolbar is clicked, the focus hops to the parent
      # window. We need to refocus it back into the iframe. Focusing breaks IE
      # and kills the range so the focus is only for Webkit. It does not affect
      # Firefox.
      @api.win.focus() if Browser.isWebkit
      @api.clean()

  return InlineStyler

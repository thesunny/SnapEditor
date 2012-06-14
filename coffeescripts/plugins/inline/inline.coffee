define ["jquery.custom", "core/browser"], ($, Browser) ->
  class InlineStyler
    register: (@api) ->

    getUI: (ui) ->
      bold = ui.button(action: "bold", description: "Bold", shortcut: "Ctrl+B", icon: { url: @api.assets.image("text_bold.png"), width: 24, height: 24, offset: [3, 3] })
      italic = ui.button(action: "italic", description: "Italic", shortcut: "Ctrl+I", icon: { url: @api.assets.image("text_italic.png"), width: 24, height: 24, offset: [3, 3] })
      return {
        "toolbar:default": "inline"
        inline: [bold, italic]
        bold: bold
        italic: italic
      }

    getActions: ->
      return {
        bold: @bold
        italic: @italic
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.b": "bold"
        "ctrl.i": "italic"
      }

    # Bolds the selected text.
    #
    # NOTE: IE uses <strong>. Other browsers use <b>.
    bold: =>
      @update() if @api.formatInline("b")

    # Italicizes the selected text.
    #
    # NOTE: IE uses <em>. Other browsers use <i>.
    italic: =>
      @update() if @api.formatInline("i")

    update: ->
      # In Firefox, when a user clicks on the toolbar to style, the
      # editor loses focus. Instead, the focus is set on the toolbar
      # button (even though unselectable="on"). Whenever the user
      # types a character, it inserts it into the editor, but also
      # presses the toolbar button. This can result in alternating
      # behaviour. For example, if I click on the list button. When
      # I start typing, it will toggle lists on and off.
      # This cannot be called for IE because it will cause the window to scroll
      # and jump. Hence this is only for Firefox.
      @api.el.focus() if Browser.isMozilla
      @api.clean()
      @api.update()

  return InlineStyler

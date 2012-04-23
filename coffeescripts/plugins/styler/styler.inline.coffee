define ["jquery.custom", "core/browser"], ($, Browser) ->
  class InlineStyler
    register: (@api) ->

    getDefaultToolbar: ->
      "Inline"

    getToolbar: (ui) ->
      bold = ui.button(action: "bold", attrs: { class: "bold-button", title: "Bold (Ctrl+B)" })
      italic = ui.button(action: "italic", attrs: { class: "italic-button", title: "Italic (Ctrl+I)" })
      return {
        Inline: [bold, italic]
        Bold: bold
        Italic: italic
      }

    getToolbarActions: ->
      return {
        bold: @bold
        italic: @italic
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.b": @bold
        "ctrl.i": @italic
      }

    # Bolds the selected text.
    #
    # NOTE: IE uses <strong>. Other browsers use <b>.
    bold: =>
      @format("b")

    # Italicizes the selected text.
    #
    # NOTE: IE uses <em>. Other browsers use <i>.
    italic: =>
      @format("i")

    # Formats the selected text given the tag.
    format: (tag) ->
      # Gecko defaults to styling with CSS. We want to disable that.
      # NOTE: This disables styling with CSS for the entire document, not just
      # for this editor.
      document.execCommand("styleWithCSS", false, false) if Browser.isGecko
      switch tag
        when "b" then @exec("bold")
        when "i" then @exec("italic")
        else throw "The inline style for tag #{tag} is unsupported"
      @update()

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
      @api.update()

    # Calls the document's execCommand with the second argument as false.
    exec: (command, value = null) ->
      document.execCommand(command, false, value)

  return InlineStyler

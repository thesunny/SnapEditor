define ["cs!core/browser"], (Browser) ->
  class InlineStyler
    register: (@api) ->

    getDefaultToolbar: ->
      "Inline"

    getToolbar: ->
      bold = ["class": "bold-button", title: "Bold (Ctrl+B)", event: "bold"]
      italic = ["class": "italic-button", title: "Italic (Ctrl+I)", event: "italic"]
      return {
        Inline: bold.concat(italic)
        Bold: bold,
        Italic: italic
      }

    getToolbarActions: ->
      return {
        bold: @bold,
        italic: @italic
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
      @api.update()

    # Calls the document's execCommand with the second argument as false.
    exec: (command, value = null) ->
      document.execCommand(command, false, value)

  return InlineStyler

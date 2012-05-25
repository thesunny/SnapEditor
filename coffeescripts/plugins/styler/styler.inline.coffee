define ["jquery.custom", "core/browser"], ($, Browser) ->
  class InlineStyler
    register: (@api) ->

    getDefaultToolbar: ->
      "Inline"

    getUI: (ui) ->
      bold = ui.button(action: "bold", description: "Bold", shortcut: "Ctrl+B", icon: { url: @api.assets.image("toolbar.png"), width: 31, height: 24, offset: [0, -101] })
      italic = ui.button(action: "italic", description: "Italic", shortcut: "Ctrl+I", icon: { url: @api.assets.image("toolbar.png"), width: 30, height: 24, offset: [-31, -101] })
      link = ui.button(action: "link", description: "Insert Link", shortcut: "Ctrl+K", icon: { url: @api.assets.image("toolbar.png"), width: 31, height: 24, offset: [0, -77] })
      return {
        "toolbar:default": "inline"
        inline: [bold, italic, link]
        bold: bold
        italic: italic
        link: link
      }

    getActions: ->
      return {
        bold: @bold
        italic: @italic
        link: @link
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.b": "bold"
        "ctrl.i": "italic"
        "ctrl.k": "link"
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

    # Calls the document's execCommand with the second argument as false.
    exec: (command, value = null) ->
      document.execCommand(command, false, value)

    # TODO:
    # NOTE:
    # You cannot use this method to call up a prompt because the preventDefault()
    # does not work properly in Firefox. The default action (go to search box)
    # still fires for some reason. The solution is probably to use our own
    # input boxes so we'll have to do that by ourself later. For now, we just
    # use default 'http://'
    #
    # I did try using the setTimeout but in Firefox, the function loses its
    # context making it difficult to locate the insertLinkDialog method that
    # we used to launch the prompt. IE isn't the only quirky browser.
    #
    # TODO: In opera, preventDefault doesn't work so it keeps popping up a dialog.
    link: =>
      href = prompt("Enter URL of link", "http://")
      if href
        href = $.trim(href)
        parentLink = @api.getParentElement("a")
        # if a parentLink is found, then just change the href
        if parentLink
          $(parentLink).attr("href", href)
        # if range is collapsed, then insert a new link
        else if @api.isCollapsed()
          link = $("<a href=\"#{href}\">#{href}</a>")
          @api.paste(link[0])
        # if range is not collapsed, then surround contents with the new link
        else
          link = $("<a href=\"#{href}\"></a>")
          @api.surroundContents(link[0])
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
      @api.clean()
      @api.update()

  return InlineStyler

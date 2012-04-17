define ["cs!jquery.custom", "cs!core/browser"], ($, Browser) ->
  class InlineStyler
    register: (@api) ->

    getDefaultToolbar: ->
      "Inline"

    getToolbar: ->
      bold = "class": "bold-button", title: "Bold (Ctrl+B)", event: "bold"
      italic = "class": "italic-button", title: "Italic (Ctrl+I)", event: "italic"
      link = "class": "link-button", title: "Link (Ctrl+K)", event: "link"
      return {
        Inline: [bold, italic, link]
        Bold: bold,
        Italic: italic,
        Link: link
      }

    getToolbarActions: ->
      return {
        bold: @bold,
        italic: @italic,
        link: @link
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.b": @bold,
        "ctrl.i": @italic,
        "ctrl.k": @link
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
      @api.update()

    # Calls the document's execCommand with the second argument as false.
    exec: (command, value = null) ->
      document.execCommand(command, false, value)

  return InlineStyler

define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  class BlockStyler
    constructor: (options = {}) ->
      @options =
        table: [2, 3]
      $.extend(@options, options)

    register: (@api) ->

    getDefaultToolbar: ->
      "Insert"

    getToolbar: (ui) ->
      link = ui.button(action: "link", attrs: { class: "link-button", title: "Insert Link (Ctrl+K)" })
      table = ui.button(action: "table", attrs: {class: "table-button", title: "Insert Table (Ctrl+Shift+T)"})
      return {
        Insert: [link, table]
        Link: link
        Table: table
      }

    getToolbarActions: ->
      return {
        link: @link
        table: @table
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.k": @link
        "ctrl.shift.t": @table
      }

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

    table: =>
      # Build the table.
      table = $('<table id="INSERTED_TABLE"></table>')
      tbody = $("<tbody/>").appendTo(table)
      td = $("<td>&nbsp;</td>")
      tr = $("<tr/>")
      tr.append(td.clone()) for i in [1..@options.table[1]]
      tbody.append(tr.clone()) for i in [1..@options.table[0]]

      # Add the table.
      @api.paste(table[0])

      # Set the cursor inside the first td of the table. Then remove the id.
      table = $("#INSERTED_TABLE")
      @api.selectEndOfTableCell(table.find("td")[0])
      table.removeAttr("id")

      # Update.
      @update()

    exec: (cmd, value = null) ->
      document.execCommand(cmd, false, value)

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

  return BlockStyler

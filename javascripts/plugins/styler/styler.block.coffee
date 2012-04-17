define ["cs!jquery.custom", "cs!core/browser", "cs!core/helpers"], ($, Browser, Helpers) ->
  class BlockStyler
    constructor: (options = {}) ->
      @options =
        table: [2, 3]
      $.extend(@options, options)

    register: (@api) ->

    getDefaultToolbar: ->
      "Block"

    getToolbar: ->
      p = "class": "p-button", title: "Paragraph (Ctrl+Space)", event: "p"
      h1 = "class": "h1-button", title: "H1 (Ctrl+1)", event: "h1"
      h2 = "class": "h2-button", title: "H2 (Ctrl+2)", event: "h2"
      h3 = "class": "h3-button", title: "H3 (Ctrl+3)", event: "h3"
      alignLeft = "class": "alignleft-button", title: "Align Left (Ctrl+L)", event: "alignleft"
      alignCenter = "class": "aligncenter-button", title: "Align Center (Ctrl+E)", event: "aligncenter"
      alignRight = "class": "alignright-button", title: "Align Right (Ctrl+R)", event: "alignright"
      unorderedList = "class": "unorderedlist-button", title: "Bullet List (Ctrl+8)", event: "unorderedlist"
      orderedList = "class": "orderedlist-button", title: "Numbered List (Ctrl+7)", event: "orderedlist"
      indent = "class": "indent-button", title: "Indent", event: "indent"
      outdent = "class": "outdent-button", title: "Outdent", event: "outdent"
      table = "class": "table-button", title: "Insert Table (Ctrl+Shift+T)", event: "table"
      return {
        Block: [p, h1, h2, h3, alignLeft, alignCenter, alignRight, unorderedList, orderedList, indent, outdent, table],
        P: p,
        H1: h1,
        H2: h2,
        H3: h3,
        AlignLeft: alignLeft,
        AlignCenter: alignCenter,
        AlignRight: alignRight,
        UnorderedList: unorderedList
        OrderedList: orderedList,
        Indent: indent,
        Outdent: outdent,
        Table: table
      }

    getToolbarActions: ->
      return {
        p: @p,
        h1: @h1,
        h2: @h2,
        h3: @h3,
        alignleft: @alignLeft,
        aligncenter: @alignCenter,
        alignright: @alignRight,
        unorderedlist: @unorderedList,
        orderedlist: @orderedList,
        indent: @indent,
        outdent: @outdent,
        table: @table
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.space": @p,
        "ctrl.1": @h1,
        "ctrl.2": @h2,
        "ctrl.3": @h3,
        "ctrl.l": @alignLeft,
        "ctrl.e": @alignCenter,
        "ctrl.r": @alignRight,
        "ctrl.8": @unorderedList,
        "ctrl.7": @orderedList,
        "ctr.shift.t": @table
      }

    p: =>
      @formatBlock('p')
      @update()

    h1: =>
      @formatBlock('h1')
      @update()

    h2: =>
      @formatBlock('h2')
      @update()

    h3: =>
      @formatBlock('h3')
      @update()

    formatBlock: (tag) =>
      # TODO-SH:
      # In Chrome, formatting a block with a p tag removes any span formatting
      # like bold and italic. May have to create a special version just for
      # webkit (Chrome and Safari).

      # ie required the angled brackets around the tag or it fails
      @exec("formatblock", "<#{tag}>")
      @update()

    alignLeft: =>
      @align("left")

    alignCenter: =>
      @align("center")

    alignRight: =>
      @align("right")

    # position can be left, center, right.
    align: (position) ->
      command = "justify#{Helpers.capitalize(position)}"
      try
        @exec(command)
      catch e
        # Bug #2027: Cannot align first line of text in FF
        # This is a bug in Mozilla FireFox itself.
        # Copied the patch from comment #8 and modified it.
        # https:#bugzilla.mozilla.org/show_bug.cgi?id=442186#c8
        # The basic idea is to insert a dummy element before the first element.
        # This way, we're not aligning the first element and the bug doesn't
        # show up. After alignment, the dummy element is removed.
        # TODO-WW: When the bug is finally fixed, we can remove the whole entire
        # try/catch block.

        #special case for Mozilla Bug #442186
        if e and e.result == 2147500037
          #probably firefox bug 442186 - workaround
          range = window.getSelection().getRangeAt(0)
          dummy = document.createElement('span')

          # Wesley: Commented out the search for the contentEditable element
          # since we already have it (@el).
          #find node with contentEditable
          #ceNode = range.startContainer.parentNode
          #while (ceNode && ceNode.contentEditable != 'true') ->
            #ceNode = ceNode.parentNode
          #}
          #if !ceNode throw 'Selected node is not editable!' }
          ceNode = @el

          ceNode.insertBefore(dummy, ceNode.childNodes[0])
          @exec(command)
          dummy.parentNode.removeChild(dummy)
        else if console and console.log
          console.log(e)
      @update()

    unorderedList: =>
      @exec("insertunorderedlist")
      @update()

    orderedList: =>
      @exec("insertorderedlist")
      @update()

    indent: =>
      @exec("indent")
      @update()

    outdent: =>
      @exec("outdent")
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

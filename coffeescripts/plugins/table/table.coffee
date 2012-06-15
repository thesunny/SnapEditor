define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  class Table
    constructor: (options = {}) ->
      @options =
        table: [2, 3]
      $.extend(@options, options)

    register: (@api) ->
      @api.on("activate.editor", @activate)
      @api.on("deactivate.editor", @deactivate)

    getUI: (ui) ->
      insertTable = ui.button(action: "insertTable", description: "Insert Table", shortcut: "Ctrl+Shift+T", icon: { url: @api.assets.image("table.png"), width: 24, height: 24, offset: [3, 3] })
      addRowAbove = ui.button(action: "addRowAbove", description: "Add Row Above", shortcut: "Ctrl+Shift+Enter", icon: { url: @api.assets.image("contextmenu.png"), width: 16, height: 16, offset: [0, -16] })
      addRowBelow = ui.button(action: "addRowBelow", description: "Add Row Below", shortcut: "Ctrl+Enter", icon: { url: @api.assets.image("contextmenu.png"), width: 16, height: 16, offset: [-16, -16] })
      deleteRow = ui.button(action: "deleteRow", description: "Delete Row", icon: { url: @api.assets.image("contextmenu.png"), width: 16, height: 16, offset: [-32, -16] })
      addColLeft = ui.button(action: "addColLeft", description: "Add Column Left", shortcut: "Ctrl+Shift+M", icon: { url: @api.assets.image("contextmenu.png"), width: 16, height: 16, offset: [-48, -16] })
      addColRight = ui.button(action: "addColRight", description: "Add Column Right", shortcut: "Ctrl+M", icon: { url: @api.assets.image("contextmenu.png"), width: 16, height: 16, offset: [-64, -16] })
      deleteCol = ui.button(action: "deleteCol", description: "Delete Column", icon: { url: @api.assets.image("contextmenu.png"), width: 16, height: 16, offset: [-80, -16] })
      deleteTable = ui.button(action: "deleteTable", description: "Delete Table", icon: { url: @api.assets.image("contextmenu.png"), width: 16, height: 16, offset: [-96, -16] })
      return {
        "toolbar:default": "table"
        table: insertTable
        "context:table": [addRowAbove, addRowBelow, deleteRow, addColLeft, addColRight, deleteCol, deleteTable]
      }

    getActions: ->
      return {
        insertTable: @insertTable
        deleteTable: (e) => @deleteTable()
        addRowAbove: Helpers.pass(@addRow, true, this)
        addRowBelow: Helpers.pass(@addRow, false, this)
        deleteRow: @deleteRow
        addColLeft: Helpers.pass(@addCol, true, this)
        addColRight: Helpers.pass(@addCol, false, this)
        deleteCol: @deleteCol
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.shift.t": "table"
        "ctrl.shift.enter": "addRowAbove"
        "ctrl.enter": "addRowBelow"
        "ctrl.shift.m": "addColLeft"
        "ctrl.m": "addColRight"
      }

    insertTable: =>
      if @api.isValid()
        if @api.getParentElement("table, li")
          alert("Sorry. This action cannot be performed inside a table or list.")
        else
          # Build the table.
          $table = $('<table id="INSERTED_TABLE"></table>')
          $tbody = $("<tbody/>").appendTo($table)
          $td = $("<td>&nbsp;</td>")
          $tr = $("<tr/>")
          $tr.append($td.clone()) for i in [1..@options.table[1]]
          $tbody.append($tr.clone()) for i in [1..@options.table[0]]

          # Add the table.
          @api.paste($table[0])

          # Set the cursor inside the first td of the table. Then remove the id.
          $table = $("#INSERTED_TABLE")
          @api.selectEndOfElement($table.find("td")[0])
          $table.removeAttr("id")

          # Update.
          @update()

    # Deletes the entire table. If no table is passed in, it attempts to the
    # find a table that contains the range.
    deleteTable: (table) =>
      table = table or @api.getParentElement("table")
      if table
        $table = $(table)
        # In IE, when the table is destroyed, the cursor is placed at the
        # beginning of the next text.
        # In W3C browsers, the cursor is lost. Instead of destroying the table,
        # we replace it with a paragraph and set the cursor there. Note that
        # this doesn't work in IE because selecting the end of the inserted
        # paragraph places the cursor at the start of the next element.
        if Browser.hasW3CRanges
          $p = $("<p>#{Helpers.zeroWidthNoBreakSpace}</p>")
          $table.replaceWith($p)
          @api.selectEndOfElement($p[0])
        else
          $table.remove()
        @update()


    # Inserts a new row. The first argument specifies whether the row should
    # appear before or after the current row.
    addRow: (before) =>
      cell = @getCell()
      if cell
        $cell = $(cell)
        $tr = $cell.parent("tr")
        $tds = $tr.children()
        $newTr = $("<tr/>")
        $newTr.append($("<td>#{Helpers.zeroWidthNoBreakSpace}</td>")) for i in [1..$tds.length]
        $tr[if before then "before" else "after"]($newTr)
        # Put the cursor in the first td of the newly added tr.
        @api.selectEndOfElement($newTr.children("td")[0])
        @update()

    # Deletes a row and moves the caret to the first cell in the next row.
    # If no next row, moves caret to first cell in previous row. If no more
    # rows, deletes the table.
    deleteRow: =>
      tr = @api.getParentElement("tr")
      if tr
        $tr = $(tr)
        $defaultTr = $tr.next("tr")
        $defaultTr = $tr.prev("tr") unless $defaultTr.length > 0
        if $defaultTr.length > 0
          # NOTE: Place the selection first before removing the row. This is
          # crucial in IE9. If we remove the row first, IE9 loses the range and
          # craps out on the selection.
          @api.selectEndOfElement($defaultTr.children()[0])
          $tr.remove()
        else
          @deleteTable($tr.closest("table", @api.el)[0])
        @update()

    # inserts a new column. The first argument specifies whether the column
    # should appear before or after the current column.
    addCol: (before) =>
      cell = @getCell()
      if cell
        $cell = $(cell)
        @eachCellInCol($cell, ->
          newCell = $(this).clone(false).html(Helpers.zeroWidthNoBreakSpace)
          $(this)[if before then "before" else "after"](newCell)
        )
        $nextCell = $cell[if before then "prev" else "next"]($cell.tagName())
        # Put the cursor in the newly added column beside the original cell.
        @api.selectEndOfElement($nextCell[0])
        @update()

    # deletes column and moves cursor to right. If no right cell, to left.
    # If no left or right, it deletes the whole table.
    deleteCol: =>
      cell = @getCell()
      if cell
        $cell = $(cell)
        $defaultCell = $cell.next()
        $defaultCell = $cell.prev() unless $defaultCell.length > 0
        if $defaultCell.length > 0
          # NOTE: Place the selection first before removing the row. This is
          # crucial in IE9. If we remove the row first, IE9 loses the range and
          # craps out on the selection.
          @api.selectEndOfElement($defaultCell[0])
          @eachCellInCol($cell, -> $(this).remove())
        else
          @deleteTable($cell.closest("table", @api.el))
        @update()

    # Find the currently selected cell (i.e. td or th).
    getCell: ->
      @api.getParentElement((el) ->
        tag = $(el).tagName()
        tag == 'td' or tag == 'th'
      )

    # This function iterates through a single column of cells based on the
    # cell passed in.
    eachCellInCol: (cell, fn) ->
      $cell = $(cell)
      $tr = $cell.parent("tr")
      $cells = $tr.children()
      for i in [0..$cells.length-1]
        break if $cells[i] == $cell[0]
      for row in $tr.parent().children("tr")
        fn.apply($(row).children()[i])

    # NOTE: Leaving this here for now because I'm not sure if we'll need it.
    # Change the tag of the current cell (th or td are expected values).
    #tag: (tag) ->
      #cell = @getCell()
      #if cell
        #$cell = cell
        #cellTag = $cell.tagName()
        #if cellTag != tag
          #newCell($("<#{tag}/>").html($cell.html()))
          #$cell.replaceWith(newCell)
          #@api.selectEndOfElement(newCell.get(0))

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

    activate: =>
      $(@api.el).on("keydown", @onkeydown)

    deactivate: =>
      $(@api.el).off("keydown", @onkeydown)

    onkeydown: (e) =>
      keys = Helpers.keysOf(e)
      if (keys == "tab" or keys == "shift.tab")
        cell = @getCell()
        if cell
          e.preventDefault()
          @moveToSiblingCell(cell, keys == "tab")

    # Move to a sibling cell. If this is the last cell, add a new row and move
    # to the first cell in the new row.
    # Arguments:
    # cell - current cell
    # next - true to move to next cell, false to move to previous cell
    moveToSiblingCell: (cell, next) ->
      siblingCell = @findSiblingCell(cell, next)
      if siblingCell
        @api.selectEndOfElement(siblingCell)
      else
        # Add a row if we are at the bottom and we want the next sibling.
        @addRow(false) if next

    # Find the sibling cell. Returns null if none is found.
    # Arguments:
    # cell - current cell
    # next - true to find next cell, false to find previous cell
    findSiblingCell: (cell, next) ->
      $cell = $(cell)
      direction = if next then "next" else "prev"
      # Find the immediate sibling.
      $siblingCell = $cell[direction]("td, th")
      # If there is no immediate sibling, go to the sibling row.
      if $siblingCell.length == 0
        $parentRow = $cell.parent("tr")
        $siblingRow = $parentRow[direction]("tr")
        # If there is a sibling row, grab the sibling cell from the sibling row.
        if $siblingRow.length > 0
          position = if direction == "next" then "first" else "last"
          $siblingCell = $siblingRow.find("td, th")[position]()
      return $siblingCell[0] or null

  return Table

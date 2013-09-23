# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "plugins/helpers", "core/browser"], ($, Helpers, Browser) ->
  table =
    activate: (@api) ->
      self = this
      @handleKeydownHandler = (e) -> self.handleKeydown(e)
      $(@api.el).on("keydown", @handleKeydownHandler)

    deactivate: ->
      $(@api.el).off("keydown", @handleKeydownHandler)

    insertTable: ->
      if @api.isValid()
        if @api.getParentElement("table, li")
          alert("Sorry. This action cannot be performed inside a table or list.")
        else
          # Build the table.
          $table = $(@api.createElement("table")).attr("id", "INSERTED_TABLE")
          $tbody = $(@api.createElement("tbody")).appendTo($table)
          $td = $(@api.createElement("td")).html("&nbsp")
          $tr = $(@api.createElement("tr"))
          $tr.append($td.clone()) for i in [1..3]
          $tbody.append($tr.clone()) for i in [1..2]

          # Handle the special case when inserting at the end of the editable
          # area.
          isEndOfEditableArea = @api.isEndOfElement(@api.el)

          # Add the table.
          @api.insert($table[0])

          # Find the table.
          $table = $(@api.find("#INSERTED_TABLE"))
          # If the table is being inserted at the end of the editable area,
          # insert the default block afterwards. This fixes several problems:
          # 1. When there is nothing after the table, it is possible to
          #    navigate to the outside of the end of the table and end up at
          #    the top level of the editable area without being in a block.
          #    This causes problems because you can now add text which is not
          #    contained in a block. The editor depends on there being top
          #    level blocks. It is fairly easy to get into this situation by
          #    using the down/right arrows, using ctrl + end, or clicking to
          #    the right side of the table.
          # 2. When there is nothing after the table, certain browsers do not
          #    allow you to navigate to the outside of the end of the table.
          #    This becomes a problem when you want to add more stuff after the
          #    table. There is no way to do this.
          # At the moment, this seems to be the best way to handle these issues.
          # Unfortunately, we can still get into the above situations if the
          # user decides to remove the <p> after the table. Fortunately, not
          # all browsers die:
          # - Firefox, IE9/7 work fine after removal of the <p> as long as the
          #   below mitigation technique is used.
          # - IE8 does not allow (1) if there is nothing after the table.
          #   However, it gets into (2). There is no fix for (2) yet.
          # - Webkit will die from (1).
          # To mitigate (1), the enter handler runs the autocleaner when the
          # range does not have a parent. However, there is still an issue
          # which is discussed below in (b). Note that this does not solve the
          # entire problem. The enter handler is still half broken and the
          # erase handler is broken. When in (1), the erase handler throws an
          # error. However, the editor still continues to work.
          # Other methods included:
          # a. To fix (1), we could prevent the situation from occurring by
          #    never allowing the user to be at the top level. However, this
          #    proved difficult because the cases were hard to catch. We were
          #    able to catch the down/right arrows because we knew when we were
          #    leaving the table. However, ctrl + end and clicking required to
          #    know the surrounds of the selection which is difficult.
          # b. To fix (1), we could rely on the autocleaner, which actually
          #    works. Unfortunately, there were two problems. The first being
          #    when to trigger the autocleaner. This is believed to be fairly
          #    simple to solve. The second was that the autocleaner would add
          #    an empty <p> after the table. Unfortunately, because there is
          #    no text in the <p> the cursor jumps before the <p> and after the
          #    table which leaves us back at the top level and an extra <p>.
          #    After investigating whether we can add a zero-width-no-breakspace
          #    it was determined that it would be too hacky and ad hoc. The
          #    problem is that the autocleaner uses #keepRange which adds two
          #    spans to keep track of the range. The cleaner sees two spans at
          #    the top level so it wraps it in the default block. #keepRange
          #    then sets the range to the spans and removes them.
          #    Unfortunately, because there is no text, the range jumps to
          #    before the <p> and after the table. Both the autocleaner and
          #    #keepRange are doing their job. We would need to add an edge
          #    case to either piece which would need to be aware of its context
          #    which is difficult.
          # c. To fix (1), we could patch up the pieces that are breaking after
          #    the fact that the top level situation has already occurred. This
          #    would be the flip solution to the preventative measures outlined
          #    above. We would let the situation happen and then attempt to
          #    mitigate the problems. There are two pieces that break when
          #    there is text at the top level: the enter handler and the erase
          #    handler. Working through the enter handler caused problems. We
          #    were able to rely partly on the autocleaner. When there was
          #    text, the autocleaner worked perfectly. Unfortunately, if there
          #    was no text and you just hit enter, we run into the autocleaner
          #    issue above. Again, to fix this issue, we would need to know the
          #    context of the range and its surroundings which is difficult.
          # d. To fix (2), we could listen to the down/right arrows. For the
          #    down arrow, if we are in the last row, we would add the default
          #    block after the table and place the range inside. For the right
          #    arrow, if we are in the last row and last column, we would add
          #    the default block after the table and place the range inside.
          #    The right arrow may be possible to implement, but unfortunately,
          #    the down arrow seems difficult. The issue is when the text spans
          #    several lines in a cell. We only want to override the browser's
          #    default down behaviour when we're on the last line of the cell.
          if isEndOfEditableArea
            $block = $(@api.getDefaultBlock()).html(Helpers.zeroWidthNoBreakSpace)
            $block.insertAfter($table)
          # Set the cursor inside the first td of the table. Then remove the id.
          @api.selectEndOfElement($table.find("td")[0])
          $table.removeAttr("id")
          @api.clean()

    # Deletes the entire table. If no table is passed in, it attempts to find
    # a table that contains the range.
    deleteTable: (table) ->
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
          $p = $(@api.createElement("p")).html(Helpers.zeroWidthNoBreakSpace)
          $table.replaceWith($p)
          @api.selectEndOfElement($p[0])
        else
          $table.remove()
        @api.clean()

    # Inserts a new row. Set before to true to insert the row above.
    addRow: (before) ->
      cell = @getCell()
      if cell
        $cell = $(cell)
        $tr = $cell.parent("tr")
        $tds = $tr.children()
        $newTr = $(@api.createElement("tr"))
        $newTr.append($(@api.createElement("td")).html(Helpers.zeroWidthNoBreakSpace)) for i in [1..$tds.length]
        $tr[if before then "before" else "after"]($newTr)
        # Put the cursor in the first td of the newly added tr.
        @api.selectEndOfElement($newTr.children("td")[0])
        @api.clean()

    # Deletes a row and moves the caret to the first cell in the next row.
    # If no next row, moves caret to first cell in previous row. If no more
    # rows, deletes the table.
    deleteRow: ->
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
        @api.clean()

    # Inserts a new column. Set before to true to insert the column to the
    # left.
    addColumn: (before) ->
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
        @api.clean()

    # Deletes column and moves cursor to right. If no right cell, to left.
    # If no left or right, it deletes the whole table.
    deleteColumn: ->
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
        @api.clean()

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

    handleKeydown: (e) ->
      keys = Helpers.keysOf(e)
      if keys == "tab" or keys == "shift+tab"
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
      siblingCell = Helpers.getSiblingCell(cell, next)
      if siblingCell
        @api.selectEndOfElement(siblingCell)
      else
        # Add a row if we are at the bottom and we want the next sibling.
        @addRow(false) if next

  SnapEditor.actions.insertTable = -> table.insertTable()
  SnapEditor.actions.addRowAbove = Helpers.pass(table.addRow, true, table)
  SnapEditor.actions.addRowBelow = Helpers.pass(table.addRow, false, table)
  SnapEditor.actions.deleteRow = -> table.deleteRow()
  SnapEditor.actions.addColumnLeft = Helpers.pass(table.addColumn, true, table)
  SnapEditor.actions.addColumnRight = Helpers.pass(table.addColumn, false, table)
  SnapEditor.actions.deleteColumn = -> table.deleteColumn()
  SnapEditor.actions.deleteTable = -> table.deleteTable()

  includeBehaviours = (e) -> e.api.config.behaviours.push("table")
  $.extend(SnapEditor.buttons,
    table:
      text: SnapEditor.lang.table
      items: ["insertTable", "|", "addRowAbove", "addRowBelow", "deleteRow", "|", "addColumnLeft", "addColumnRight", "deleteColumn", "|", "deleteTable", "|", "styleTable", "styleRow", "styleCell"]
    insertTable: Helpers.createButton("insertTable", "", langKey: "tableInsert", onInclude: (e) ->
      includeBehaviours(e)
      e.api.on("snapeditor.plugins_ready", (e) ->
        e.api.addWhitelistRule(
          table: SnapEditor.getSelectorFromStyleKey(e.api.getStyleButtonsByTag("style-table")[0] or "table")
          "Table Body": "tbody"
          tr: SnapEditor.getSelectorFromStyleKey(e.api.getStyleButtonsByTag("style-table-row")[0] or "tr")
          td: SnapEditor.getSelectorFromStyleKey(e.api.getStyleButtonsByTag("style-table-cell")[0] or "td") + " > BR"
        )
        # Change th to td unless th styling is defined.
        cellStyles = e.api.getStyleButtonsByTag("style-table-cell")
        thFound = false
        for style in cellStyles
          thFound = style.split(".").shift() == "th"
          break if thFound
        e.api.addWhitelistRule("th", "td > BR") unless thFound
      )
    )
    addRowAbove: Helpers.createButton("addRowAbove", "ctrl+shift+enter", langKey: "tableAddRowAbove", onInclude: includeBehaviours)
    addRowBelow: Helpers.createButton("addRowBelow", "ctrl+enter", langKey: "tableAddRowBelow", onInclude: includeBehaviours)
    deleteRow: Helpers.createButton("deleteRow", "", langKey: "tableDeleteRow", onInclude: includeBehaviours)
    addColumnLeft: Helpers.createButton("addColumnLeft", "ctrl+shift+m", langKey: "tableAddColumnLeft", onInclude: includeBehaviours)
    addColumnRight: Helpers.createButton("addColumnRight", "ctrl+m", langKey: "tableAddColumnRight", onInclude: includeBehaviours)
    deleteColumn: Helpers.createButton("deleteColumn", "", langKey: "tableDeleteColumn", onInclude: includeBehaviours)
    deleteTable: Helpers.createButton("deleteTable", "", langKey: "tableDelete", onInclude: includeBehaviours)
  )
  SnapEditor.addStyleList("styleTable", SnapEditor.lang.styleTable, "style-table")
  SnapEditor.addStyleList("styleRow", SnapEditor.lang.styleRow, "style-table-row")
  SnapEditor.addStyleList("styleCell", SnapEditor.lang.styleCell, "style-table-cell")

  SnapEditor.behaviours.table =
    onActivate: (e) -> table.activate(e.api)
    onDeactivate: -> table.deactivate()

  SnapEditor.insertStyles("plugins_table", Helpers.createStyles("table", 22 * -26))

  # table is returned for testing purposes.
  return table

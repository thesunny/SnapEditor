require ["plugins/table/table", "core/helpers", "core/range"], (Table, Helpers, Range) ->
  describe "Table", ->
    $editable = $before = $after = $table = api = table = null
    beforeEach ->
      $editable = addEditableFixture()
      $before = $("<div>before</div>").appendTo($editable)
      $table = $("
        <table>
          <tbody>
            <tr class='first'><th class='1'>h1</th><th class='2'>h2</th></tr>
            <tr class='middle'><td class='1'>1.1</td><td class='2'>1.2</td></tr>
            <tr class='last'><td class='1'>2.1</td><td td class='2'>2.2</td></tr>
          </tbody>
        </table>
      ").appendTo($editable)
      $after = $("<div>after</div>").appendTo($editable)
      table = new Table()
      table.api =
        createElement: (name) -> document.createElement(name)
        find: (selector) -> $(selector)
        range: (el) -> new Range($editable[0], el or window)
        blankRange: -> new Range($editable[0])
        isValid: -> true
      spyOn(table, "update")
      Helpers.delegate(table.api, "range()", "getParentElement", "paste")
      Helpers.delegate(table.api, "blankRange()", "selectEndOfElement")

    afterEach ->
      $editable.remove()

    describe "#insertTable", ->
      placeSelection =  null
      beforeEach ->
        placeSelection = ->
          range = new Range($editable[0])
          if hasW3CRanges
            range.range.setStart($before[0].childNodes[0], 2)
          else
            range.range.findText("fore")
            range.collapse(true)
          range.select()

      it "inserts a table where the selection is", ->
        placeSelection()
        table.insertTable()
        expect($before.find("table").length).toEqual(1)
        # NOTE: IE adds newlines before blocks. Remove them.
        expect(clean($before.html())).toMatch("be<table>.*</table>fore")

      it "inserts a table with no id", ->
        placeSelection()
        table.insertTable()
        expect($before.find("table").attr("id")).toBeUndefined()

      it "inserts a table with the correct format", ->
        placeSelection()
        table.insertTable()
        expect($before.find("table").attr("id")).toBeUndefined()

      it "places the selection at the end of the first <td>", ->
        placeSelection()
        table.insertTable()
        range = new Range($editable[0], window)
        range.paste("<b></b>")
        expect(clean($before.find("td").html())).toEqual("&nbsp;<b></b>")

      it "updates the api", ->
        placeSelection()
        table.insertTable()
        expect(table.update).toHaveBeenCalled()

    describe "#deleteTable", ->
      placeSelection = null
      beforeEach ->
        placeSelection = ->
          range = new Range($editable[0])
          range.selectEndOfElement($table.find("td")[0])

      it "deletes the given table", ->
        placeSelection()
        table.deleteTable($table[0])
        expect($editable.find("table").length).toEqual(0)

      it "deletes the selected table", ->
        placeSelection()
        table.deleteTable()
        expect($editable.find("table").length).toEqual(0)

      if hasW3CRanges
        it "replaces the table with a p and places the caret at the end of it", ->
          placeSelection()
          table.deleteTable()
          $p = $editable.find("p")
          expect($p.length).toEqual(1)
          range = new Range($editable[0], window)
          range.paste("<b></b>")
          expect($p.find("b").length).toEqual(1)
      else
        it "places the caret at the end of the previous text", ->
          placeSelection()
          table.deleteTable()
          range = new Range($editable[0], window)
          range.paste("<b></b>")
          expect(clean($after.html())).toEqual("<b></b>after")

      it "updates the api", ->
        placeSelection()
        table.deleteTable()
        expect(table.update).toHaveBeenCalled()

    describe "#addRow", ->
      it "inserts a row before when no row is before", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".first").find("th")[0])
        table.addRow(true)
        $trs = $table.find("tr")
        expect($trs.length).toEqual(4)
        expect($($trs[1]).hasClass("first")).toBeTruthy()
        expect($($trs[2]).hasClass("middle")).toBeTruthy()
        expect($($trs[3]).hasClass("last")).toBeTruthy()

      it "inserts a row before when a row is before", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".middle").find("td")[0])
        table.addRow(true)
        $trs = $table.find("tr")
        expect($trs.length).toEqual(4)
        expect($($trs[0]).hasClass("first")).toBeTruthy()
        expect($($trs[2]).hasClass("middle")).toBeTruthy()
        expect($($trs[3]).hasClass("last")).toBeTruthy()

      it "inserts a row after when no row is after", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".last").find("td")[0])
        table.addRow(false)
        $trs = $table.find("tr")
        expect($trs.length).toEqual(4)
        expect($($trs[0]).hasClass("first")).toBeTruthy()
        expect($($trs[1]).hasClass("middle")).toBeTruthy()
        expect($($trs[2]).hasClass("last")).toBeTruthy()

      it "inserts a row after when a row is after", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".middle").find("td")[0])
        table.addRow(false)
        $trs = $table.find("tr")
        expect($trs.length).toEqual(4)
        expect($($trs[0]).hasClass("first")).toBeTruthy()
        expect($($trs[1]).hasClass("middle")).toBeTruthy()
        expect($($trs[3]).hasClass("last")).toBeTruthy()

      it "places the selection in the first cell of the new row", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".first").find("th")[0])
        table.addRow(true)
        range = new Range($editable[0], window)
        range.paste("<b></b>")
        expect($($table.find("td")[0]).find("b").length).toEqual(1)

      it "updates the api", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".first").find("th")[0])
        table.addRow(true)
        expect(table.update).toHaveBeenCalled()

    describe "#deleteRow", ->
      it "deletes the row when there are other rows in the table", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".first").find("th")[0])
        table.deleteRow()
        expect($table.find("tr").length).toEqual(2)
        expect($(".first").length).toEqual(0)

      it "deletes the table when there are no other rows in the table", ->
        $(".middle").remove()
        $(".last").remove()
        range = new Range($editable[0])
        range.selectEndOfElement($(".first").find("th")[0])
        table.deleteRow()
        expect($("table").length).toEqual(0)

      it "places the caret at the end of the first cell of the next row", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".first").find("th")[0])
        table.deleteRow()
        range = new Range($editable[0], window)
        range.paste("<b></b>")
        expect($($(".middle").find("td")[0]).find("b").length).toEqual(1)

      it "places the caret at the end of the first cell of the previous row when there is no next row", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".last").find("td")[0])
        table.deleteRow()
        range = new Range($editable[0], window)
        range.paste("<b></b>")
        expect($($(".middle").find("td")[0]).find("b").length).toEqual(1)

      it "updates the api", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".first").find("th")[0])
        table.deleteRow()
        expect(table.update).toHaveBeenCalled()

    describe "#addCol", ->
      it "inserts a column before when there is no column before", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".1")[0])
        table.addCol(true)
        $trs = $table.find("tr")
        $tr = $($trs[0])
        $cells = $tr.find("th")
        expect($cells.length).toEqual(3)
        expect($($cells[1]).hasClass("1")).toBeTruthy()
        expect($($cells[2]).hasClass("2")).toBeTruthy()
        $tr = $($trs[1])
        $cells = $tr.find("td")
        expect($cells.length).toEqual(3)
        expect($($cells[1]).hasClass("1")).toBeTruthy()
        expect($($cells[2]).hasClass("2")).toBeTruthy()
        $tr = $($trs[2])
        $cells = $tr.find("td")
        expect($cells.length).toEqual(3)
        expect($($cells[1]).hasClass("1")).toBeTruthy()
        expect($($cells[2]).hasClass("2")).toBeTruthy()

      it "inserts a column before when there is a column before", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".2")[0])
        table.addCol(true)
        $trs = $table.find("tr")
        $tr = $($trs[0])
        $cells = $tr.find("th")
        expect($cells.length).toEqual(3)
        expect($($cells[0]).hasClass("1")).toBeTruthy()
        expect($($cells[2]).hasClass("2")).toBeTruthy()
        $tr = $($trs[1])
        $cells = $tr.find("td")
        expect($cells.length).toEqual(3)
        expect($($cells[0]).hasClass("1")).toBeTruthy()
        expect($($cells[2]).hasClass("2")).toBeTruthy()
        $tr = $($trs[2])
        $cells = $tr.find("td")
        expect($cells.length).toEqual(3)
        expect($($cells[0]).hasClass("1")).toBeTruthy()
        expect($($cells[2]).hasClass("2")).toBeTruthy()

      it "inserts a column after when there is no column after", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".2")[0])
        table.addCol(false)
        $trs = $table.find("tr")
        $tr = $($trs[0])
        $cells = $tr.find("th")
        expect($cells.length).toEqual(3)
        expect($($cells[0]).hasClass("1")).toBeTruthy()
        expect($($cells[1]).hasClass("2")).toBeTruthy()
        $tr = $($trs[1])
        $cells = $tr.find("td")
        expect($cells.length).toEqual(3)
        expect($($cells[0]).hasClass("1")).toBeTruthy()
        expect($($cells[1]).hasClass("2")).toBeTruthy()
        $tr = $($trs[2])
        $cells = $tr.find("td")
        expect($cells.length).toEqual(3)
        expect($($cells[0]).hasClass("1")).toBeTruthy()
        expect($($cells[1]).hasClass("2")).toBeTruthy()

      it "inserts a column after when there is a column after", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".1")[0])
        table.addCol(false)
        $trs = $table.find("tr")
        $tr = $($trs[0])
        $cells = $tr.find("th")
        expect($cells.length).toEqual(3)
        expect($($cells[0]).hasClass("1")).toBeTruthy()
        expect($($cells[2]).hasClass("2")).toBeTruthy()
        $tr = $($trs[1])
        $cells = $tr.find("td")
        expect($cells.length).toEqual(3)
        expect($($cells[0]).hasClass("1")).toBeTruthy()
        expect($($cells[2]).hasClass("2")).toBeTruthy()
        $tr = $($trs[2])
        $cells = $tr.find("td")
        expect($cells.length).toEqual(3)
        expect($($cells[0]).hasClass("1")).toBeTruthy()
        expect($($cells[2]).hasClass("2")).toBeTruthy()

      it "places the caret in the new column beside the original cell", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".1")[1])
        table.addCol(true)
        range = new Range($editable[0], window)
        range.paste("<b></b>")
        expect($($(".middle").find("td")[0]).find("b").length).toEqual(1)

      it "updates the api", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".1")[0])
        table.addCol(true)
        expect(table.update).toHaveBeenCalled()

    describe "#deleteCol", ->
      it "deletes the column if there are other columns in the table", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".1")[0])
        table.deleteCol()
        $trs = $table.find("tr")
        $tr = $($trs[0])
        $cells = $tr.find("th")
        expect($cells.length).toEqual(1)
        expect($($cells[0]).hasClass("2")).toBeTruthy()
        $tr = $($trs[1])
        $cells = $tr.find("td")
        expect($cells.length).toEqual(1)
        expect($($cells[0]).hasClass("2")).toBeTruthy()
        $tr = $($trs[2])
        $cells = $tr.find("td")
        expect($cells.length).toEqual(1)
        expect($($cells[0]).hasClass("2")).toBeTruthy()

      it "deletes the table if there are no other columns in the table", ->
        $(".2").remove()
        range = new Range($editable[0])
        range.selectEndOfElement($(".1")[0])
        table.deleteCol()
        expect($editable.find("table").length).toEqual(0)

      it "places the caret in the next cell if it exists", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".1")[1])
        table.deleteCol()
        range = new Range($editable[0], window)
        range.paste("<b></b>")
        expect($($(".2")[1]).find("b").length).toEqual(1)

      it "places the caret in the previous cell if the next cell does not exist", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".2")[1])
        table.deleteCol()
        range = new Range($editable[0], window)
        range.paste("<b></b>")
        expect($($(".1")[1]).find("b").length).toEqual(1)

      it "updates the api", ->
        range = new Range($editable[0])
        range.selectEndOfElement($(".1")[0])
        table.deleteCol()
        expect(table.update).toHaveBeenCalled()

    describe "#getCell", ->
      it "returns null when no cell is selected", ->
        range = new Range($editable[0], $before[0])
        range.select()
        expect(table.getCell()).toBeNull()

      it "returns the selected th", ->
        range = new Range($editable[0])
        range.selectEndOfElement($table.find("th")[0])
        th = table.getCell()
        expect(th).not.toBeNull()
        expect(th.tagName.toLowerCase()).toEqual("th")

      it "returns the selected td", ->
        range = new Range($editable[0])
        range.selectEndOfElement($table.find("td")[0])
        td = table.getCell()
        expect(td).not.toBeNull()
        expect(td.tagName.toLowerCase()).toEqual("td")

    describe "#eachCellInCol", ->
      it "calls the function for each cell in the column and binds it to the cell", ->
        table.eachCellInCol($table.find("td")[0], -> expect($(this).hasClass("1")).toBeTruthy())

    describe "#findSiblingCell", ->
      describe "next", ->
        it "returns the immediate sibling when there is one", ->
          sibling = table.findSiblingCell($table.find(".1").first(), true)
          expect(sibling.innerHTML).toEqual("h2")

        it "returns the first cell in the next row when there is no immediate sibling", ->
          sibling = table.findSiblingCell($table.find(".2").first(), true)
          expect(sibling.innerHTML).toEqual("1.1")

        it "returns null when there is no sibling", ->
          sibling = table.findSiblingCell($table.find(".2").last(), true)
          expect(sibling).toBeNull()

      describe "previous", ->
        it "returns the immediate sibling when there is one", ->
          sibling = table.findSiblingCell($table.find(".2").last(), false)
          expect(sibling.innerHTML).toEqual("2.1")

        it "returns the last cell in the previous row when there is no immediate sibling", ->
          sibling = table.findSiblingCell($table.find(".1").last(), false)
          expect(sibling.innerHTML).toEqual("1.2")

        it "returns null when there is no sibling", ->
          sibling = table.findSiblingCell($table.find(".1").first(), false)
          expect(sibling).toBeNull()

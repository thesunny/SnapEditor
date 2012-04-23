describe "Styler.Block", ->
  required = ["plugins/styler/styler.block", "core/range"]

  $editable = $div = null
  beforeEach ->
    $editable = addEditableFixture()
    $div = $("<div>some text</div>").appendTo($editable)

  afterEach ->
    $editable.remove()

  describe "#table", ->
    API = placeSelection =  null
    beforeEach ->
      class API
        constructor: (@Range) ->
        range: -> new @Range($editable[0], window)
        paste: (arg) -> @range().paste(arg)
        selectEndOfTableCell: (cell) -> @range().selectEndOfTableCell(cell)
      placeSelection = (Range) ->
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($div[0].childNodes[0], 5)
        else
          range.range.findText("text")
          range.collapse(true)
        range.select()

    ait "inserts a table where the selection is", required, (Styler, Range) ->
      placeSelection(Range)
      styler = new Styler()
      styler.api = new API(Range)
      spyOn(styler, "update")
      styler.table()
      expect($div.find("table").length).toEqual(1)
      # NOTE: IE adds newlines before blocks. Remove them.
      expect($div.html().toLowerCase().replace(/[\n\r]/g, "")).toMatch("some <table>.*</table>text")

    ait "inserts a table with no id", required, (Styler, Range) ->
      placeSelection(Range)
      styler = new Styler()
      styler.api = new API(Range)
      spyOn(styler, "update")
      styler.table()
      expect($div.find("table").attr("id")).toBeUndefined()

    ait "inserts a table with the correct format", required, (Styler, Range) ->
      placeSelection(Range)
      styler = new Styler()
      styler.api = new API(Range)
      spyOn(styler, "update")
      styler.table()
      expect($div.find("table").attr("id")).toBeUndefined()

    ait "places the selection at the end of the first <td>", required, (Styler, Range) ->
      placeSelection(Range)
      styler = new Styler()
      styler.api = new API(Range)
      spyOn(styler, "update")
      styler.table()
      range = new Range($editable[0], window)
      range.paste("<b></b>")
      expect($div.find("td").html().toLowerCase()).toEqual("&nbsp;<b></b>")

    ait "updates the api", required, (Styler, Range) ->
      placeSelection(Range)
      styler = new Styler()
      styler.api = new API(Range)
      spyOn(styler, "update")
      styler.table()
      expect(styler.update).toHaveBeenCalled()

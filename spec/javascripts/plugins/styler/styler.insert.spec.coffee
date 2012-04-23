require ["plugins/styler/styler.insert", "core/range"], (Styler, Range) ->
  describe "Styler.Insert", ->
    $editable = $div = null
    beforeEach ->
      $editable = addEditableFixture()
      $div = $("<div>some text</div>").appendTo($editable)

    afterEach ->
      $editable.remove()

    describe "#link", ->
      API = null
      beforeEach ->
        spyOn(window, "prompt").andReturn("http://snapeditor.com")
        class API
          constructor: (@Range) ->
          range: -> new @Range($editable[0], window)
          isCollapsed: -> @range().isCollapsed()
          getParentElement: (match) -> @range().getParentElement(match)
          paste: (arg) -> @range().paste(arg)
          surroundContents: (el) -> @range().surroundContents(el)

      it "does not do anything if nothing is entered", ->
        window.prompt.andReturn(null)
        styler = new Styler()
        spyOn(styler, "update")
        styler.link()
        expect(styler.update).not.toHaveBeenCalled()

      it "changes the href if a link is selected", ->
        $a = $('<a href="http://example.com">some text</a>').appendTo($editable)
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($a[0].childNodes[0], 5)
        else
          range.range.findText("text")
          range.collapse(true)
        range.select()

        styler = new Styler()
        styler.api = new API(Range)
        spyOn(styler, "update")
        styler.link()
        expect($a.attr("href")).toEqual("http://snapeditor.com")

      it "adds a link if the range is collapsed", ->
        $div = $("<div>some text</div>").appendTo($editable)

        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($div[0].childNodes[0], 5)
        else
          range.range.findText("text")
        range.collapse(true)
        range.select()

        styler = new Styler()
        styler.api = new API(Range)
        spyOn(styler, "update")
        styler.link()
        if isIE7
          expect($div.html().toLowerCase()).toEqual('some <a href="http://snapeditor.com/">http://snapeditor.com</a>text')
        else
          expect($div.html().toLowerCase()).toEqual('some <a href="http://snapeditor.com">http://snapeditor.com</a>text')

      it "surrounds the content with a link", ->
        $div = $("<div>some text</div>").appendTo($editable)
        $span = $div.find("span")
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($div[0].childNodes[0], 5)
          range.range.setEnd($div[0].childNodes[0], 9)
        else
          range.range.findText("text")
        range.select()

        styler = new Styler()
        styler.api = new API(Range)
        spyOn(styler, "update")
        styler.link()
        if isIE7
          expect($div.html().toLowerCase()).toEqual('some <a href="http://snapeditor.com/">text</a>')
        else
          expect($div.html().toLowerCase()).toEqual('some <a href="http://snapeditor.com">text</a>')

      it "updates the api", ->
        $a = $('<a href="http://example.com">some text</a>').appendTo($editable)
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($a[0].childNodes[0], 5)
        else
          range.range.findText("text")
          range.collapse(true)
        range.select()

        styler = new Styler()
        styler.api = new API(Range)
        spyOn(styler, "update")
        styler.link()
        expect(styler.update).toHaveBeenCalled()

    describe "#table", ->
      API = placeSelection =  null
      beforeEach ->
        class API
          range: -> new Range($editable[0], window)
          paste: (arg) -> @range().paste(arg)
          selectEndOfTableCell: (cell) -> @range().selectEndOfTableCell(cell)
        placeSelection = ->
          range = new Range($editable[0])
          if hasW3CRanges
            range.range.setStart($div[0].childNodes[0], 5)
          else
            range.range.findText("text")
            range.collapse(true)
          range.select()

      it "inserts a table where the selection is", ->
        placeSelection()
        styler = new Styler()
        styler.api = new API()
        spyOn(styler, "update")
        styler.table()
        expect($div.find("table").length).toEqual(1)
        # NOTE: IE adds newlines before blocks. Remove them.
        expect($div.html().toLowerCase().replace(/[\n\r]/g, "")).toMatch("some <table>.*</table>text")

      it "inserts a table with no id", ->
        placeSelection()
        styler = new Styler()
        styler.api = new API()
        spyOn(styler, "update")
        styler.table()
        expect($div.find("table").attr("id")).toBeUndefined()

      it "inserts a table with the correct format", ->
        placeSelection()
        styler = new Styler()
        styler.api = new API()
        spyOn(styler, "update")
        styler.table()
        expect($div.find("table").attr("id")).toBeUndefined()

      it "places the selection at the end of the first <td>", ->
        placeSelection()
        styler = new Styler()
        styler.api = new API()
        spyOn(styler, "update")
        styler.table()
        range = new Range($editable[0], window)
        range.paste("<b></b>")
        expect($div.find("td").html().toLowerCase()).toEqual("&nbsp;<b></b>")

      it "updates the api", ->
        placeSelection()
        styler = new Styler()
        styler.api = new API()
        spyOn(styler, "update")
        styler.table()
        expect(styler.update).toHaveBeenCalled()

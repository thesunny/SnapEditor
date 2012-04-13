# When checking an element's HTML, we use #toLowerCase()
# because IE returns the HTML tags as uppercase.
unless hasW3CRanges
  describe "Range.IE", ->
    required = ["cs!core/range/range.ie", "cs!core/helpers"]

    Range = $editable = $start = $end = null
    beforeEach ->
      class Range
      $editable = addEditableFixture()
      $start = $('<div id="start">start</div>').appendTo($editable)
      $end = $('<div id="end">end</div>').appendTo($editable)
      # IE8 requires the focus to be on $editable in order
      # for ranges to work properly.
      $editable.focus()

    afterEach ->
      $editable.remove()

    describe "static functions", ->
      describe ".getBlankRange", ->
        ait "returns a new range", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          spyOn(document.body, "createTextRange").andReturn("range")
          range = Range.getBlankRange()
          expect(range).toEqual("range")
          expect(document.body.createTextRange).toHaveBeenCalled()

      describe ".getRangeFromSelection", ->
        ait "returns the selected range", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)

          # Create a selection.
          expectedRange = Range.getRangeFromElement($start[0])
          expectedRange.collapse(true)
          expectedRange.select()

          actualRange = Range.getRangeFromSelection()
          expect(actualRange.text.length).toEqual(0)

          # Insert a span and ensure it is in the correct place.
          actualRange.pasteHTML("<span/>")
          expect($start.html().toLowerCase()).toEqual("<span></span>start")

      describe ".getRangeFromElement", ->
        ait "returns a TextRange encompassing the contents of the element when it is not an image", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          range = Range.getRangeFromElement($start[0])
          range.execCommand("delete")
          # In IE, when returning attributes, the values are not wrapped in "".
          expect($editable.html().toLowerCase()).toEqual("<div id=end>end</div>")

        ait "returns a ControlRange that includes the element when it is image", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          $img = $('<img />').appendTo($editable)
          range = Range.getRangeFromElement($img[0])
          expect(range.text).toBeUndefined()
          expect(range.length).toEqual(1)
          expect(range.item(0)).toBe($img[0])

    describe "instance functions", ->
      describe "#isCollapsed", ->
        ait "returns whether the range is collapsed", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.range = Range.getRangeFromElement($start[0])
          expect(range.isCollapsed()).toBeFalsy()
          range.range.collapse(true)
          expect(range.isCollapsed()).toBeTruthy()

      describe "#isImageSelected", ->
        $img = null
        beforeEach ->
          $img = $('<img style="width:100px;height:200px"/>').appendTo($editable)

        ait "returns false if text is selected", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.range = Range.getRangeFromElement($start[0])
          expect(range.isImageSelected()).toBeFalsy()

        ait "returns false if text and image is selected", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          $end = $("<div>image end</div>").appendTo($editable)

          endRange = Range.getRangeFromElement($end[0])
          range = new Range()
          range.range = Range.getRangeFromElement($start[0])
          range.range.setEndPoint("EndToEnd", endRange)
          expect(range.isImageSelected()).toBeFalsy()

        ait "returns true if image is selected", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.range = Range.getRangeFromElement($img[0])
          expect(range.isImageSelected()).toBeTruthy()

        ait "returns true if image is already selected", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.range = Range.getRangeFromElement($img[0])
          range.select()
          range.range = Range.getRangeFromSelection()
          expect(range.isImageSelected()).toBeTruthy()

      describe "#getImmediateParentElement", ->
        ait "returns the immediate parent of a TextRange", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.range = Range.getRangeFromElement($start[0])
          range.range.collapse(true)
          expect(range.getImmediateParentElement()).toBe($start[0])

        ait "returns null of a ControlRange", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.range = $editable[0].createControlRange()
          expect(range.getImmediateParentElement()).toBeNull()

      describe "#select", ->
        ait "selects the given range even if it has its own", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          givenRange = Range.getRangeFromElement($start[0])
          ownRange = Range.getRangeFromElement($end[0])

          range = new Range()
          range.range = ownRange
          range.select(givenRange)
          expect(document.selection.createRange().text).toEqual("start")

        ait "selects its own range if none is given", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          ownRange = Range.getRangeFromElement($start[0])

          range = new Range()
          range.range = ownRange
          range.select()
          expect(document.selection.createRange().text).toEqual("start")

        ait "keeps the range when no range is given", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          expectedRange = Range.getBlankRange()

          range = new Range()
          range.range = expectedRange
          range.select()
          expect(range.range).toBe(expectedRange)

        ait "saves the given range", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          expectedRange = Range.getBlankRange()

          range = new Range()
          range.select(expectedRange)
          expect(range.range).toBe(expectedRange)

        ait "returns itself", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          expect(range.select(Range.getBlankRange())).toBe(range)

      describe "#unselect", ->
        ait "unselects the current range", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.select(Range.getRangeFromElement($start[0]))
          expect(document.selection.createRange().text).toEqual("start")
          range.unselect()
          expect(document.selection.createRange().text).toEqual("")

      describe "#selectEndOfTableCell", ->
        ait "selects the end of the inside of the cell when there is content", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          $table = $('<table><tbody><tr><td id="td">before</td><td>after</td></tr></tbody></table>').appendTo($editable)
          $td = $("#td")

          range = new Range()
          range.selectEndOfTableCell($td[0])

          actualRange = document.selection.createRange()
          actualRange.pasteHTML("<span></span>")
          expect($td.html().toLowerCase()).toEqual("before<span></span>")

        ait "selects the end of the inside of the cell when there is no content", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          $table = $('<table><tbody><tr><td id="td"></td><td>after</td></tr></tbody></table>').appendTo($editable)
          $td = $("#td")

          range = new Range()
          range.selectEndOfTableCell($td[0])

          actualRange = document.selection.createRange()
          actualRange.pasteHTML("<span></span>")
          expect($td.html().toLowerCase()).toEqual("<span></span>")

      describe "#pasteNode", ->
        ait "pastes the given element node", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          spyOn(range, "pasteHTML")
          range.pasteNode($("<span/>")[0])
          expect(range.pasteHTML).toHaveBeenCalledWith("<SPAN></SPAN>")

        ait "pastes the given text node", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          spyOn(range, "pasteHTML")
          range.pasteNode(document.createTextNode("test"))
          expect(range.pasteHTML).toHaveBeenCalledWith("test")

      describe "#pasteHTML", ->
        describe "collapsed", ->
          ait "inserts elements", required, (Module, Helpers) ->
            Helpers.extend(Range, Module.static)
            Helpers.include(Range, Module.instance)

            range = new Range()
            range.range = Range.getRangeFromElement($start[0])
            range.range.collapse(true)
            range.pasteHTML("<span><b>bold</b></span><div><ul><li>item</li></ul></div>")
            # Need to remove whitespace because IE adds random whitespace in
            # between elements.
            expect($start.html().toLowerCase().replace(/\s*/g, "")).toEqual("<span><b>bold</b></span><div><ul><li>item</li></ul></div>start")

          ait "inserts text", required, (Module, Helpers) ->
            Helpers.extend(Range, Module.static)
            Helpers.include(Range, Module.instance)

            range = new Range()
            range.range = Range.getRangeFromElement($start[0])
            range.range.collapse(true)
            range.pasteHTML("test")
            expect($start.html().toLowerCase()).toEqual("teststart")

          ait "puts the selection after the HTML", required, (Module, Helpers) ->
            Helpers.extend(Range, Module.static)
            Helpers.include(Range, Module.instance)

            range = new Range()
            range.range = Range.getRangeFromElement($start[0])
            range.range.collapse(true)
            range.pasteHTML("<span></span>")

            actualRange = document.selection.createRange()
            actualRange.pasteHTML("<b></b>")
            expect($start.html().toLowerCase()).toEqual("<span></span><b></b>start")

        describe "not collapsed", ->
          ait "inserts elements", required, (Module, Helpers) ->
            Helpers.extend(Range, Module.static)
            Helpers.include(Range, Module.instance)

            range = new Range()
            range.range = Range.getBlankRange()
            range.range.findText("start")
            range.pasteHTML("<span></span>")
            expect($start.html().toLowerCase()).toEqual("<span></span>")

          ait "inserts text", required, (Module, Helpers) ->
            Helpers.extend(Range, Module.static)
            Helpers.include(Range, Module.instance)

            range = new Range()
            range.range = Range.getBlankRange()
            range.range.findText("start")
            range.pasteHTML("test")
            expect($start.html().toLowerCase()).toEqual("test")

          ait "puts the selection after the text", required, (Module, Helpers) ->
            Helpers.extend(Range, Module.static)
            Helpers.include(Range, Module.instance)

            range = new Range()
            range.range = Range.getBlankRange()
            range.range.findText("start")
            range.pasteHTML("test")

            actualRange = document.selection.createRange()
            actualRange.pasteHTML("<b></b>")
            expect($start.html().toLowerCase()).toEqual("test<b></b>")

          ait "puts the selection after the elements", required, (Module, Helpers) ->
            Helpers.extend(Range, Module.static)
            Helpers.include(Range, Module.instance)

            range = new Range()
            range.range = Range.getBlankRange()
            range.range.findText("start")
            range.pasteHTML("<span>test</span>")

            actualRange = document.selection.createRange()
            actualRange.pasteHTML("<b></b>")
            expect($start.html().toLowerCase()).toEqual("<span>test<b></b></span>")

      describe "#surroundContents", ->
        ait "inserts the given HTML", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          spyOn(range, "pasteNode")
          range.range = Range.getBlankRange()
          range.range.findText("start")
          range.surroundContents($("<span/>")[0])

          expect(range.pasteNode).toHaveBeenCalled()
          # Check the first argument to the first call to #pasteNode.
          # We're expecting the argument to be the node "<span>start</span>".
          el = range.pasteNode.argsForCall[0][0]
          expect(el.tagName).toEqual("SPAN")
          expect(el.innerHTML).toEqual("start")

      describe "#remove", ->
        ait "removes the contents of the range", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.range = Range.getBlankRange()
          range.range.findText("start")
          range.remove()
          expect($start.html()).toEqual("")

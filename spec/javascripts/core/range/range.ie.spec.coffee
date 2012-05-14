# When checking an element's HTML, we use #toLowerCase()
# because IE returns the HTML tags as uppercase.
unless hasW3CRanges
  require ["core/range/range.ie", "core/helpers"], (Module, Helpers) ->
    describe "Range.IE", ->
      Range = $editable = $start = $end = null
      beforeEach ->
        class Range
          getParentElements: ->
        Helpers.extend(Range, Module.static)
        Helpers.include(Range, Module.instance)
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
          it "returns a new range", ->
            spyOn(document.body, "createTextRange").andReturn("range")
            range = Range.getBlankRange()
            expect(range).toEqual("range")
            expect(document.body.createTextRange).toHaveBeenCalled()

        describe ".getRangeFromSelection", ->
          it "returns the selected range", ->
            # Create a selection.
            expectedRange = Range.getRangeFromElement($start[0])
            expectedRange.collapse(true)
            expectedRange.select()

            actualRange = Range.getRangeFromSelection()
            expect(actualRange.text.length).toEqual(0)

            # Insert a span and ensure it is in the correct place.
            actualRange.pasteHTML("<span/>")
            expect(clean($start.html())).toEqual("<span></span>start")

        describe ".getRangeFromElement", ->
          it "returns a TextRange encompassing the contents of the element when it is not an image", ->
            range = Range.getRangeFromElement($start[0])
            range.execCommand("delete")
            # In IE, when returning attributes, the values are not wrapped in "".
            expect(clean($editable.html())).toEqual("<div id=end>end</div>")

          it "returns a ControlRange that includes the element when it is image", ->
            $img = $('<img />').appendTo($editable)
            range = Range.getRangeFromElement($img[0])
            expect(range.text).toBeUndefined()
            expect(range.length).toEqual(1)
            expect(range.item(0)).toBe($img[0])

      describe "instance functions", ->
        describe "#isCollapsed", ->
          it "returns whether the range is collapsed", ->
            range = new Range()
            range.range = Range.getRangeFromElement($start[0])
            expect(range.isCollapsed()).toBeFalsy()
            range.range.collapse(true)
            expect(range.isCollapsed()).toBeTruthy()

        describe "#isImageSelected", ->
          $img = null
          beforeEach ->
            $img = $('<img style="width:100px;height:200px"/>').appendTo($editable)

          it "returns false if text is selected", ->
            range = new Range()
            range.range = Range.getRangeFromElement($start[0])
            expect(range.isImageSelected()).toBeFalsy()

          it "returns false if text and image is selected", ->
            $end = $("<div>image end</div>").appendTo($editable)

            endRange = Range.getRangeFromElement($end[0])
            range = new Range()
            range.range = Range.getRangeFromElement($start[0])
            range.range.setEndPoint("EndToEnd", endRange)
            expect(range.isImageSelected()).toBeFalsy()

          it "returns true if image is selected", ->
            range = new Range()
            range.range = Range.getRangeFromElement($img[0])
            expect(range.isImageSelected()).toBeTruthy()

          it "returns true if image is already selected", ->
            range = new Range()
            range.range = Range.getRangeFromElement($img[0])
            range.select()
            range.range = Range.getRangeFromSelection()
            expect(range.isImageSelected()).toBeTruthy()

        describe "#isEndOfElement", ->
          $text = textnode = null
          beforeEach ->
            $text = $("<div>text \t  \n\t      \n\n\t</div>").appendTo($editable)
            textnode = $text[0].childNodes[0]

          it "returns true if range is at the end", ->
            range = new Range()
            range.range = Range.getBlankRange()
            # Place the selection at the end of "text|".
            range.range.findText("text")
            range.range.collapse(false)
            expect(range.isEndOfElement($text[0])).toBeTruthy()

          it "returns false if range is not at the end", ->
            range = new Range()
            range.range = Range.getBlankRange()
            # Place the selection in the middle of "te|xt".
            range.range.findText("xt")
            range.range.collapse(true)
            expect(range.isEndOfElement($text[0])).toBeFalsy()

          it "returns false if &nbsp; is after", ->
            $text.html("text&nbsp;")
            textnode = $text[0].childNodes[0]

            range = new Range()
            range.range = Range.getBlankRange()
            # Place the selection at the end of "text|".
            range.range.findText("text")
            range.range.collapse(false)
            expect(range.isEndOfElement($text[0])).toBeFalsy()

        describe "#getImmediateParentElement", ->
          it "returns the immediate parent of a TextRange", ->
            range = new Range()
            range.range = Range.getRangeFromElement($start[0])
            range.range.collapse(true)
            expect(range.getImmediateParentElement()).toBe($start[0])

          it "returns image of a ControlRange", ->
            $img = $('<img />').appendTo($editable)
            range = new Range()
            range.range = $editable[0].createControlRange()
            range.range.addElement($img[0])
            expect(range.getImmediateParentElement()).toBe($img[0])

        describe "#select", ->
          it "selects the given range even if it has its own", ->
            givenRange = Range.getRangeFromElement($start[0])
            ownRange = Range.getRangeFromElement($end[0])

            range = new Range()
            range.range = ownRange
            range.select(givenRange)
            expect(document.selection.createRange().text).toEqual("start")

          it "selects its own range if none is given", ->
            ownRange = Range.getRangeFromElement($start[0])

            range = new Range()
            range.range = ownRange
            range.select()
            expect(document.selection.createRange().text).toEqual("start")

          it "keeps the range when no range is given", ->
            expectedRange = Range.getBlankRange()

            range = new Range()
            range.range = expectedRange
            range.select()
            expect(range.range).toBe(expectedRange)

          it "saves the given range", ->
            expectedRange = Range.getBlankRange()

            range = new Range()
            range.select(expectedRange)
            expect(range.range).toBe(expectedRange)

          it "returns itself", ->
            range = new Range()
            expect(range.select(Range.getBlankRange())).toBe(range)

        describe "#unselect", ->
          it "unselects the current range", ->
            range = new Range()
            range.select(Range.getRangeFromElement($start[0]))
            expect(document.selection.createRange().text).toEqual("start")
            range.unselect()
            expect(document.selection.createRange().text).toEqual("")

        describe "#selectEndOfElement", ->
          it "selects the end of the inside of the element when there is content", ->
            range = new Range()
            range.el = $editable[0]
            range.range = Range.getBlankRange()
            range.selectEndOfElement($start[0])

            actualRange = document.selection.createRange()
            actualRange.pasteHTML("<span></span>")
            expect(clean($start.html())).toEqual("start<span></span>")
            p $editable.html()

          it "selects the end of the inside of the cell when there is content", ->
            $table = $('<table><tbody><tr><td id="td">before</td><td>after</td></tr></tbody></table>').appendTo($editable)
            $td = $("#td")

            range = new Range()
            range.range = Range.getBlankRange()
            range.selectEndOfElement($td[0])

            actualRange = document.selection.createRange()
            actualRange.pasteHTML("<span></span>")
            expect(clean($td.html())).toEqual("before<span></span>")

          it "selects the end of the inside of the cell when there is no content", ->
            $table = $('<table><tbody><tr><td id="td"></td><td>after</td></tr></tbody></table>').appendTo($editable)
            $td = $("#td")

            range = new Range()
            range.range = Range.getBlankRange()
            range.selectEndOfElement($td[0])

            actualRange = document.selection.createRange()
            actualRange.pasteHTML("<span></span>")
            expect(clean($td.html())).toEqual("<span></span>")

        describe "#keepRange", ->
          it "calls the given function", ->
            called = false
            fn = -> called = true

            range = new Range()
            range.range = Range.getBlankRange()
            range.range.findText("tar")
            range.range.collapse(true)
            range.select()

            range.keepRange(fn)
            expect(called).toBeTruthy()

          it "inserts the spans in the correct order when the range is collapsed", ->
            html = null
            range = new Range()
            range.range = Range.getBlankRange()
            range.range.findText("tar")
            range.range.collapse(true)
            range.select()
            range.keepRange(-> html = $start.html())
            expect(clean(html)).toEqual("s<span id=range_start></span><span id=range_end></span>tart")

          it "keeps the range when collapsed", ->
            range = new Range()
            range.range = Range.getBlankRange()
            range.range.findText("tar")
            range.range.collapse(true)
            range.select()
            range.keepRange(->)
            range.range = Range.getRangeFromSelection()
            range.pasteHTML("<b></b>")
            expect(clean($start.html())).toEqual("s<b></b>tart")

          it "keeps the range when not collapsed", ->
            range = new Range()
            range.range = Range.getBlankRange()
            range.range.findText("tar")
            range.select()
            range.delete()
            expect(clean($start.html())).toEqual("st")

          it "keeps the range when the function changes the range", ->
            fn = ->
              range = new Range()
              range.range = Range.getRangeFromElement($end[0])
              range.select()

            range = new Range()
            range.range = Range.getBlankRange()
            range.range.findText("tar")
            range.select()

            range.keepRange(fn)
            range.delete()
            expect(clean($start.html())).toEqual("st")

        describe "#pasteNode", ->
          it "pastes the given element node", ->
            range = new Range()
            spyOn(range, "pasteHTML")
            range.pasteNode($("<span/>")[0])
            expect(range.pasteHTML).toHaveBeenCalledWith("<SPAN></SPAN>")

          it "pastes the given text node", ->
            range = new Range()
            spyOn(range, "pasteHTML")
            range.pasteNode(document.createTextNode("test"))
            expect(range.pasteHTML).toHaveBeenCalledWith("test")

        describe "#pasteHTML", ->
          describe "collapsed", ->
            it "inserts elements", ->
              range = new Range()
              range.range = Range.getRangeFromElement($start[0])
              range.range.collapse(true)
              range.pasteHTML("<span><b>bold</b></span><div><ul><li>item</li></ul></div>")
              expect(clean($start.html())).toEqual("<span><b>bold</b></span><div><ul><li>item</li></ul></div>start")

            it "inserts text", ->
              range = new Range()
              range.range = Range.getRangeFromElement($start[0])
              range.range.collapse(true)
              range.pasteHTML("test")
              expect(clean($start.html())).toEqual("teststart")

            it "puts the selection after the HTML", ->
              range = new Range()
              range.range = Range.getRangeFromElement($start[0])
              range.range.collapse(true)
              range.pasteHTML("<span></span>")

              actualRange = document.selection.createRange()
              actualRange.pasteHTML("<b></b>")
              expect(clean($start.html())).toEqual("<span></span><b></b>start")

          describe "not collapsed", ->
            it "inserts elements", ->
              range = new Range()
              range.range = Range.getBlankRange()
              range.range.findText("start")
              range.pasteHTML("<span></span>")
              expect(clean($start.html())).toEqual("<span></span>")

            it "inserts text", ->
              range = new Range()
              range.range = Range.getBlankRange()
              range.range.findText("start")
              range.pasteHTML("test")
              expect(clean($start.html())).toEqual("test")

            it "puts the selection after the text", ->
              range = new Range()
              range.range = Range.getBlankRange()
              range.range.findText("start")
              range.pasteHTML("test")

              actualRange = document.selection.createRange()
              actualRange.pasteHTML("<b></b>")
              expect(clean($start.html())).toEqual("test<b></b>")

            it "puts the selection after the elements", ->
              range = new Range()
              range.range = Range.getBlankRange()
              range.range.findText("start")
              range.pasteHTML("<span>test</span>")

              actualRange = document.selection.createRange()
              actualRange.pasteHTML("<b></b>")
              expect(clean($start.html())).toEqual("<span>test<b></b></span>")

        describe "#surroundContents", ->
          it "inserts the given HTML", ->
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

        describe "#delete", ->
          it "deletes the contents of the range", ->
            range = new Range()
            range.range = Range.getBlankRange()
            range.range.findText("start")
            range.delete()
            expect($start.html()).toEqual("")

          it "merges the nodes if the range starts and ends in different blocks", ->
            range = new Range()
            spyOn(range, "getParentElements").andReturn([$start[0], $end[0]])
            range.range = Range.getBlankRange()
            range.range.findText("star")
            range.range.collapse(false)
            endRange = Range.getBlankRange()
            endRange.findText("en")
            range.range.setEndPoint("EndToEnd", endRange)
            range.select()
            range.delete()
            expect($editable.find("div").length).toEqual(1)
            expect($editable.find("div").html()).toEqual("stard")

          it "keeps the range", ->
            range = new Range()
            spyOn(range, "getParentElements").andReturn([$start[0], $end[0]])
            range.range = Range.getBlankRange()
            range.range.findText("star")
            range.range.collapse(false)
            endRange = Range.getBlankRange()
            endRange.findText("en")
            range.range.setEndPoint("EndToEnd", endRange)
            range.select()
            range.delete()
            range.pasteHTML("<b></b>")
            expect(clean($editable.find("div").html())).toEqual("star<b></b>d")

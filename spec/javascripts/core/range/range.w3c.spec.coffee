if hasW3CRanges
  describe "Range.W3C", ->
    required = ["cs!core/range/range.w3c", "cs!core/helpers"]

    Range = $editable = $start = $end = null
    beforeEach ->
      class Range
      $editable = addEditableFixture()
      $start = $('<div id="start">start</div>').appendTo($editable)
      $end = $('<div id="end">end</div>').appendTo($editable)

    afterEach ->
      $editable.remove()

    describe "static functions", ->
      describe ".getBlankRange", ->
        ait "returns a new range", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          spyOn(document, "createRange").andReturn("range")
          range = Range.getBlankRange()
          expect(range).toEqual("range")
          expect(document.createRange).toHaveBeenCalled()

      describe ".getRangeFromSelection", ->
        ait "returns the selected range", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)

          # Create a selection.
          expectedRange = Range.getBlankRange()
          expectedRange.selectNodeContents($start[0])
          expectedRange.collapse(true)
          selection = window.getSelection()
          selection.removeAllRanges()
          selection.addRange(expectedRange)

          actualRange = Range.getRangeFromSelection()
          expect(actualRange.collapsed).toBeTruthy()

          # Insert a span and ensure it is in the correct place.
          actualRange.insertNode($("<span/>")[0])
          expect($start.html()).toEqual("<span></span>start")

      describe ".getRangeFromElement", ->
        ait "returns a range encompassing the element", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          range = Range.getRangeFromElement($start[0])
          expect(range.collapsed).toBeFalsy()
          # Check that the range includes the entire div.
          range.deleteContents()
          expect($editable.html()).toEqual('<div id="end">end</div>')

    describe "instance functions", ->
      selection = null
      beforeEach ->
        selection = window.getSelection()

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

          imgRange = Range.getRangeFromElement($img[0])
          range = new Range()
          range.range = Range.getRangeFromElement($start[0])
          range.range.setEnd(imgRange.endContainer, imgRange.endOffset)
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

      describe "#isStartOfNode", ->
        $text = textnode = null
        beforeEach ->
          $text = $("<div>\n  \t\n \t\n    text</div>").appendTo($editable)
          textnode = $text[0].childNodes[0]

        ait "returns true if range is at the start", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.range = Range.getBlankRange()
          # Place the selection at the beginning of "|text".
          range.range.setStart(textnode, textnode.nodeValue.indexOf('t'))
          range.range.collapse(true)
          expect(range.isStartOfNode($text[0])).toBeTruthy()
          expect(range.isStartOfNode(textnode)).toBeTruthy()

        ait "returns false if range is not at the start", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.range = Range.getBlankRange()
          # Place the selection in the middle of "te|xt".
          range.range.setStart(textnode, textnode.nodeValue.indexOf('x'))
          range.range.collapse(true)
          expect(range.isStartOfNode($text[0])).toBeFalsy()
          expect(range.isStartOfNode(textnode)).toBeFalsy()

        ait "returns false if &nbsp; is before", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          $text.html("&nbsp;text")
          textnode = $text[0].childNodes[0]

          range = new Range()
          range.range = Range.getBlankRange()
          # Place the selection at the beginning of "|text".
          range.range.setStart(textnode, textnode.nodeValue.indexOf('t'))
          range.range.collapse(true)
          expect(range.isStartOfNode($text[0])).toBeFalsy()
          expect(range.isStartOfNode(textnode)).toBeFalsy()

      describe "#isEndOfNode", ->
        $text = textnode = null
        beforeEach ->
          $text = $("<div>text \t  \n\t      \n\n\t</div>").appendTo($editable)
          textnode = $text[0].childNodes[0]

        ait "returns true if range is at the end", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.range = Range.getBlankRange()
          # Place the selection at the beginning of "|text".
          range.range.setStart(textnode, textnode.nodeValue.lastIndexOf('t')+1)
          range.range.collapse(true)
          expect(range.isEndOfNode($text[0])).toBeTruthy()
          expect(range.isEndOfNode(textnode)).toBeTruthy()

        ait "returns false if range is not at the end", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.range = Range.getBlankRange()
          # Place the selection in the middle of "te|xt".
          range.range.setStart(textnode, textnode.nodeValue.indexOf('x'))
          range.range.collapse(true)
          expect(range.isEndOfNode($text[0])).toBeFalsy()
          expect(range.isEndOfNode(textnode)).toBeFalsy()

        ait "returns false if &nbsp; is after", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          $text.html("text&nbsp;")
          textnode = $text[0].childNodes[0]

          range = new Range()
          range.range = Range.getBlankRange()
          # Place the selection at the beginning of "|text".
          range.range.setStart(textnode, textnode.nodeValue.lastIndexOf('t')+1)
          range.range.collapse(true)
          expect(range.isEndOfNode($text[0])).toBeFalsy()
          expect(range.isEndOfNode(textnode)).toBeFalsy()

      describe "#getImmediateParentElement", ->
        ait "returns the immediate parent", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.range = Range.getBlankRange()
          range.range.selectNodeContents($start[0])
          range.range.collapse(true)
          selection.removeAllRanges()
          selection.addRange(range.range)
          expect(range.getImmediateParentElement()).toBe($start[0])

      # TODO: Once it is confirmed that #getStartText is not used, remove this
      # test.
      #describe "#getStartText", ->
        #ait "returns all the text from the start of its parent that matches to the range", required, (Module, Helpers) ->
          #Helpers.extend(Range, Module.static)
          #Helpers.include(Range, Module.instance)

          #range = new Range()
          #range.getParentElement = ->
          #spyOn(range, "getParentElement").andReturn($start[0])

          ## Set the range at "sta|rt"
          #range.range = Range.getBlankRange()
          #range.range.setStart($start[0].childNodes[0], 3)
          #range.range.collapse(true)

          #text = range.getStartText("match")
          #expect(text).toEqual("sta")
          #expect(range.getParentElement).toHaveBeenCalledWith("match")

      describe "#select", ->
        ait "selects the given range even if it has its own", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          givenRange = Range.getBlankRange()
          givenRange.selectNodeContents($start[0])
          ownRange = Range.getBlankRange()
          ownRange.selectNodeContents($end[0])

          range = new Range()
          range.range = ownRange
          range.select(givenRange)
          selection.getRangeAt(0).deleteContents()
          expect($start.html()).toEqual("")

        ait "selects its own range if none is given", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          ownRange = Range.getBlankRange()
          ownRange.selectNodeContents($start[0])

          range = new Range()
          range.range = ownRange
          range.select()
          selection.getRangeAt(0).deleteContents()
          expect($start.html()).toEqual("")

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
          range.select(Range.getBlankRange())
          expect(selection.rangeCount).toEqual(1)
          range.unselect()
          expect(selection.rangeCount).toEqual(0)

      describe "#selectEndOfElement", ->
        ait "selects the end of the inside of the element when there is content", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.el = $editable[0]
          range.selectEndOfElement($start[0])

          actualRange = selection.getRangeAt(0)
          actualRange.insertNode($("<span/>")[0])
          expect($start.html()).toEqual("start<span></span>")

      describe "#selectEndOfTableCell", ->
        ait "selects the end of the inside of the cell when there is content", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          $table = $('<table><tbody><tr><td id="td">before</td><td>after</td></tr></tbody></table>').appendTo($editable)
          $td = $("#td")

          range = new Range()
          range.el = $editable[0]
          range.selectEndOfTableCell($td[0])

          actualRange = selection.getRangeAt(0)
          actualRange.insertNode($("<span/>")[0])
          expect($td.html()).toEqual("before<span></span>")

        ait "selects the end of the inside of the cell when there is no content", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          $table = $('<table><tbody><tr><td id="td"></td><td>after</td></tr></tbody></table>').appendTo($editable)
          $td = $("#td")

          range = new Range()
          range.el = $editable[0]
          range.selectEndOfTableCell($td[0])

          actualRange = selection.getRangeAt(0)
          actualRange.insertNode($("<span/>")[0])
          expect($td.html()).toEqual("<span></span>")

      describe "#selectAfterElement", ->
        ait "puts the selection after the node", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          $div = $('<div><span id="span"></span>after</div>').appendTo($editable)
          $span = $("#span")

          range = new Range()
          range.range = Range.getBlankRange()
          range.selectAfterElement($span[0])

          actualRange = window.getSelection().getRangeAt(0)
          actualRange.insertNode($("<b/>")[0])
          expect($div.html()).toEqual('<span id="span"></span><b></b>after')

      describe "#pasteNode", ->
        ait "pastes the given element node", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.el = $editable
          range.range = Range.getBlankRange()
          range.range.selectNodeContents($start[0])
          range.range.collapse(true)
          range.pasteNode($("<span/>")[0])
          expect($start.html()).toEqual("<span></span>start")

        ait "pastes the given text node", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.el = $editable
          range.range = Range.getBlankRange()
          range.range.selectNodeContents($start[0])
          range.range.collapse(true)
          range.pasteNode(document.createTextNode("test"))
          expect($start.html()).toEqual("teststart")

        ait "puts the selection after the node", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          text = document.createTextNode("test")

          range = new Range()
          spyOn(range, "selectAfterElement")
          range.el = $editable
          range.range = Range.getBlankRange()
          range.range.selectNodeContents($start[0])
          range.range.collapse(true)
          range.pasteNode(text)
          expect(range.selectAfterElement).toHaveBeenCalledWith(text)


      describe "#pasteHTML", ->
        ait "inserts the given HTML", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.range = Range.getBlankRange()
          range.range.selectNodeContents($start[0])
          range.range.collapse(true)
          range.pasteHTML("<span><b>bold</b></span><div><ul><li>item</li></ul></div>")
          expect($start.html()).toEqual("<span><b>bold</b></span><div><ul><li>item</li></ul></div>start")

        ait "puts the selection after the node", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          spyOn(range, "selectAfterElement")
          range.range = Range.getBlankRange()
          range.range.selectNodeContents($start[0])
          range.range.collapse(true)
          range.pasteHTML("<span></span>")
          expect(range.selectAfterElement).toHaveBeenCalled()

      describe "#surroundContents", ->
        ait "inserts the given HTML", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.el = $editable
          range.range = Range.getBlankRange()
          range.range.selectNodeContents($start[0])
          range.surroundContents($("<span/>")[0])
          expect($start.html()).toEqual("<span>start</span>")

        ait "puts the selection after the node", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          $span = $("<span/>")

          range = new Range()
          spyOn(range, "selectAfterElement")
          range.el = $editable
          range.range = Range.getBlankRange()
          range.range.selectNodeContents($start[0])
          range.surroundContents($span[0])
          expect(range.selectAfterElement).toHaveBeenCalledWith($span[0])

      describe "#remove", ->
        ait "removes the contents of the range", required, (Module, Helpers) ->
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)

          range = new Range()
          range.range = Range.getBlankRange()
          range.range.selectNodeContents($start[0])
          range.remove()
          expect($start.html()).toEqual("")

# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
if hasW3CRanges
  require ["core/range/range.w3c", "core/helpers", "core/browser", "core/iframe"], (Module, Helpers, Browser, IFrame) ->
    describe "Range.W3C", ->
      tests = (getDocFn) ->
        Range = doc = win = createElement = find = $container = $editable = $start = $end = null
        beforeEach ->
          $container = $("<div/>").prependTo("body")
          doc = getDocFn($container)
          win = doc.defaultView or doc.parentWindow
          createElement = (name) -> $(doc.createElement(name))
          find = (selector) -> $(doc).find(selector)
          class Range
            doc: doc
            win: win
            createElement: createElement
            find: find
            getParentElements: null
          Helpers.extend(Range, Module.static)
          Helpers.include(Range, Module.instance)
          $editable = addEditableFixture(doc)
          $start = createElement("div").html("start").appendTo($editable)
          $end = createElement("div").html("end").appendTo($editable)

        afterEach ->
          $editable.remove()
          $container.remove()

        describe "static functions", ->
          describe ".getBlankRange", ->
            it "returns a new range", ->
              spyOn(doc, "createRange").andReturn("range")
              range = Range.getBlankRange(win)
              expect(range).toEqual("range")
              expect(doc.createRange).toHaveBeenCalled()

          describe ".getRangeFromSelection", ->
            it "returns the selected range", ->
              # Create a selection.
              expectedRange = Range.getBlankRange(win)
              expectedRange.selectNodeContents($start[0])
              expectedRange.collapse(true)
              selection = win.getSelection()
              selection.removeAllRanges()
              selection.addRange(expectedRange)

              actualRange = Range.getRangeFromSelection(win)
              expect(actualRange.collapsed).toBeTruthy()

              # Insert a span and ensure it is in the correct place.
              actualRange.insertNode($("<span/>")[0])
              expect($start.html()).toEqual("<span></span>start")

            it "returns null when there is no selected range", ->
              window.getSelection().removeAllRanges()
              expect(Range.getRangeFromSelection(win)).toBeNull()

          describe ".getRangeFromElement", ->
            it "returns a range encompassing the element", ->
              range = Range.getRangeFromElement($start[0])
              expect(range.collapsed).toBeFalsy()
              # Check that the range includes the entire div.
              range.deleteContents()
              expect($editable.html()).toEqual('<div>end</div>')

        describe "instance functions", ->
          selection = null
          beforeEach ->
            selection = win.getSelection()

          describe "#isCollapsed", ->
            it "returns whether the range is collapsed", ->
              range = new Range()
              range.range = Range.getRangeFromElement($start[0])
              expect(range.isCollapsed()).toBeFalsy()
              range.range.collapse(true)
              expect(range.isCollapsed()).toBeTruthy()

            it "returns false when selecting an image", ->
              $editable.html('<img src="/spec/javascripts/support/assets/images/stub.png" />')
              $img = $editable.find("img")
              range = new Range()
              range.range = Range.getRangeFromElement($img[0])
              expect(range.isCollapsed()).toBeFalsy()

          describe "#isImageSelected", ->
            $img = null
            beforeEach ->
              $img = createElement("img").css(width: 100, height: 200).appendTo($editable)

            it "returns false if text is selected", ->
              range = new Range()
              range.range = Range.getBlankRange(win)
              range.range.setStart($start[0].childNodes[0], 0)
              range.range.setEnd($start[0].childNodes[0], 5)
              range.select()
              expect(range.isImageSelected()).toBeFalsy()

            it "returns false if text and image is selected", ->
              imgRange = Range.getRangeFromElement($img[0])
              range = new Range()
              range.range = Range.getRangeFromElement($start[0])
              range.range.setEnd(imgRange.endContainer, imgRange.endOffset)
              expect(range.isImageSelected()).toBeFalsy()

            it "returns true if image is selected", ->
              range = new Range()
              range.range = Range.getRangeFromElement($img[0])
              expect(range.isImageSelected()).toBeTruthy()

            it "returns true if image is already selected", ->
              range = new Range()
              range.range = Range.getRangeFromElement($img[0])
              range.select()
              range.range = Range.getRangeFromSelection(win)
              expect(range.isImageSelected()).toBeTruthy()

          describe "#isStartOfElement", ->
            $text = textnode = null
            beforeEach ->
              $text = createElement("div").html("\n  \t#{Helpers.zeroWidthNoBreakSpace}\n \t\n    text").appendTo($editable)
              textnode = $text[0].childNodes[0]

            it "returns true if range is at the start", ->
              range = new Range()
              range.range = Range.getBlankRange(win)
              # Place the selection at the beginning of "|text".
              range.range.setStart(textnode, textnode.nodeValue.indexOf('t'))
              range.range.collapse(true)
              expect(range.isStartOfElement($text[0])).toBeTruthy()

            it "returns false if range is not at the start", ->
              range = new Range()
              range.range = Range.getBlankRange(win)
              # Place the selection in the middle of "te|xt".
              range.range.setStart(textnode, textnode.nodeValue.indexOf('x'))
              range.range.collapse(true)
              expect(range.isStartOfElement($text[0])).toBeFalsy()

            it "returns false if &nbsp; is before", ->
              $text.html("&nbsp;text")
              textnode = $text[0].childNodes[0]

              range = new Range()
              range.range = Range.getBlankRange(win)
              # Place the selection at the beginning of "|text".
              range.range.setStart(textnode, textnode.nodeValue.indexOf('t'))
              range.range.collapse(true)
              expect(range.isStartOfElement($text[0])).toBeFalsy()

            it "returns false if an image is before", ->
              $text.html('<img src="/spec/javascripts/support/assets/images/stub.png" />text')
              textnode = $text[0].childNodes[1]

              range = new Range()
              range.range = Range.getBlankRange(win)
              # Place the selection at the beginning of "|text".
              range.range.setStart(textnode, textnode.nodeValue.indexOf('t'))
              range.range.collapse(true)
              expect(range.isStartOfElement($text[0])).toBeFalsy()

          describe "#isEndOfElement", ->
            $text = textnode = null
            beforeEach ->
              $text = $("<div>text \t  \n\t      #{Helpers.zeroWidthNoBreakSpace}\n\n\t</div>").appendTo($editable)
              textnode = $text[0].childNodes[0]

            it "returns true if range is at the end", ->
              range = new Range()
              range.range = Range.getBlankRange(win)
              # Place the selection at the end of "text|".
              range.range.setStart(textnode, 4)
              range.range.collapse(true)
              expect(range.isEndOfElement($text[0])).toBeTruthy()

            it "returns false if range is not at the end", ->
              range = new Range()
              range.range = Range.getBlankRange(win)
              # Place the selection in the middle of "te|xt".
              range.range.setStart(textnode, 2)
              range.range.collapse(true)
              expect(range.isEndOfElement($text[0])).toBeFalsy()

            it "returns false if &nbsp; is after", ->
              $text.html("text&nbsp;")
              textnode = $text[0].childNodes[0]

              range = new Range()
              range.range = Range.getBlankRange(win)
              # Place the selection at the end of "text|".
              range.range.setStart(textnode, 4)
              range.range.collapse(true)
              expect(range.isEndOfElement($text[0])).toBeFalsy()

            it "returns false if an image is after", ->
              $text.html('text<img src="/spec/javascripts/support/assets/images/stub.png" />')
              textnode = $text[0].childNodes[0]

              range = new Range()
              range.range = Range.getBlankRange(win)
              # Place the selection at the end of "text|".
              range.range.setStart(textnode, 4)
              range.range.collapse(true)
              expect(range.isEndOfElement($text[0])).toBeFalsy()

          describe "#getImmediateParentElement", ->
            it "returns the immediate parent", ->
              range = new Range()
              range.range = Range.getBlankRange(win)
              range.range.selectNodeContents($start[0])
              range.range.collapse(true)
              selection.removeAllRanges()
              selection.addRange(range.range)
              expect(range.getImmediateParentElement()).toBe($start[0])

            it "returns an image when an image is selected", ->
              $editable.html('<img src="/spec/javascripts/support/assets/images/stub.png" />')
              $img = $editable.find("img")
              range = new Range()
              range.range = Range.getRangeFromElement($img[0])
              selection.removeAllRanges()
              selection.addRange(range.range)
              expect(range.getImmediateParentElement()).toBe($img[0])

          describe "#getText", ->
            it "returns the selected text when selecting only text", ->
              range = new Range()
              range.range = Range.getBlankRange(win)
              range.range.selectNodeContents($start[0])
              expect(range.getText()).toEqual("start")

            it "returns the text only when selecting HTML elements too", ->
              $img = $('<img src="/spec/javascripts/support/assets/images/stub.png" />').insertAfter($start)
              range = new Range()
              range.range = Range.getRangeFromElement($editable[0])
              expect(range.getText()).toEqual("startend")

            it "returns an empty string when an image is selected", ->
              $editable.html('<img src="/spec/javascripts/support/assets/images/stub.png" />')
              $img = $editable.find("img")
              range = new Range()
              range.range = Range.getRangeFromElement($img[0])
              expect(range.getText()).toEqual("")

          # TODO: Once it is confirmed that #getStartText is not used, remove this
          # test.
          #describe "#getStartText", ->
            #it "returns all the text from the start of its parent that matches to the range", ->
              #range = new Range()
              #range.getParentElement = ->
              #spyOn(range, "getParentElement").andReturn($start[0])

              ## Set the range at "sta|rt"
              #range.range = Range.getBlankRange(win)
              #range.range.setStart($start[0].childNodes[0], 3)
              #range.range.collapse(true)

              #text = range.getStartText("match")
              #expect(text).toEqual("sta")
              #expect(range.getParentElement).toHaveBeenCalledWith("match")

          describe "#select", ->
            it "selects the given range even if it has its own", ->
              givenRange = Range.getBlankRange(win)
              givenRange.selectNodeContents($start[0])
              ownRange = Range.getBlankRange(win)
              ownRange.selectNodeContents($end[0])

              range = new Range()
              range.range = ownRange
              range.select(givenRange)
              selection.getRangeAt(0).deleteContents()
              expect($start.html()).toEqual("")

            it "selects its own range if none is given", ->
              ownRange = Range.getBlankRange(win)
              ownRange.selectNodeContents($start[0])

              range = new Range()
              range.range = ownRange
              range.select()
              selection.getRangeAt(0).deleteContents()
              expect($start.html()).toEqual("")

            it "keeps the range when no range is given", ->
              expectedRange = Range.getBlankRange(win)

              range = new Range()
              range.range = expectedRange
              range.select()
              expect(range.range).toBe(expectedRange)

            it "saves the given range", ->
              expectedRange = Range.getBlankRange(win)

              range = new Range()
              range.select(expectedRange)
              expect(range.range).toBe(expectedRange)

            it "returns itself", ->
              range = new Range()
              expect(range.select(Range.getBlankRange(win))).toBe(range)

          describe "#unselect", ->
            it "unselects the current range", ->
              range = new Range()
              range.select(Range.getBlankRange(win))
              expect(selection.rangeCount).toEqual(1)
              range.unselect()
              expect(selection.rangeCount).toEqual(0)

          describe "#selectElementContents", ->
            it "selects the contents of an inline element", ->
              $editable.html("before<b>bold</b>after")
              range = new Range()
              range.range = Range.getBlankRange(win)
              range.selectElementContents($editable.find("b")[0])

              actualRange = selection.getRangeAt(0)
              actualRange.deleteContents()
              expect(clean($editable.html())).toEqual("before<b></b>after")

            it "selects the contents of a block element", ->
              $editable.html("before<div>block</div>after")
              range = new Range()
              range.range = Range.getBlankRange(win)
              range.selectElementContents($editable.find("div")[0])

              actualRange = selection.getRangeAt(0)
              actualRange.deleteContents()
              expect(clean($editable.html())).toEqual("before<div></div>after")

            it "select the contents of a link", ->
              $editable.html("before<a>link</a>after")
              range = new Range()
              range.range = Range.getBlankRange(win)
              range.selectElementContents($editable.find("a")[0])

              actualRange = selection.getRangeAt(0)
              actualRange.deleteContents()
              expect(clean($editable.html())).toEqual("before<a></a>after")

          describe "#selectEndOfElement", ->
            it "selects the end of the inside of the element when there is content", ->
              range = new Range()
              range.el = $editable[0]
              range.range = Range.getBlankRange(win)
              range.selectEndOfElement($start[0])

              actualRange = selection.getRangeAt(0)
              actualRange.insertNode($("<span/>")[0])
              expect($start.html()).toEqual("start<span></span>")

            it "selects the end of the inside of the cell when there is content", ->
              $table = createElement("table").html('<tbody><tr><td id="td">before</td><td>after</td></tr></tbody>').appendTo($editable)
              $td = find("#td")

              range = new Range()
              range.el = $editable[0]
              range.range = Range.getBlankRange(win)
              range.selectEndOfElement($td[0])

              actualRange = selection.getRangeAt(0)
              actualRange.insertNode($("<span/>")[0])
              expect($td.html()).toEqual("before<span></span>")

            it "selects the end of the inside of the cell when there is no content", ->
              $table = createElement("table").html('<tbody><tr><td id="td"></td><td>after</td></tr></tbody>').appendTo($editable)
              $td = find("#td")

              range = new Range()
              range.el = $editable[0]
              range.range = Range.getBlankRange(win)
              range.selectEndOfElement($td[0])

              actualRange = selection.getRangeAt(0)
              actualRange.insertNode($("<span/>")[0])
              expect($td.html()).toEqual("<span></span>")

          describe "#selectAfterElement", ->
            it "puts the selection after the node", ->
              $div = createElement("div").html('<span id="span"></span>after').appendTo($editable)
              $span = find("#span")

              range = new Range()
              range.range = Range.getBlankRange(win)
              range.selectAfterElement($span[0])

              actualRange = win.getSelection().getRangeAt(0)
              actualRange.insertNode($("<b/>")[0])
              expect($div.html()).toEqual('<span id="span"></span><b></b>after')

          describe "#keepRange", ->
            it "calls the given function", ->
              called = false
              fn = -> called = true

              range = new Range()
              range.range = Range.getBlankRange(win)
              range.range.setStart($start[0].childNodes[0], 2)
              range.range.collapse(true)
              range.select()

              range.keepRange(fn)
              expect(called).toBeTruthy()

            it "inserts the spans in the correct order when the range is collapsed", ->
              html = null
              range = new Range()
              range.range = Range.getBlankRange(win)
              range.range.setStart($start[0].childNodes[0], 2)
              range.range.collapse(true)
              range.select()
              range.keepRange(-> html = $start.html())
              expect(clean(html)).toEqual("st<span id=range_start></span><span id=range_end></span>art")

            it "keeps the range when collapsed", ->
              range = new Range()
              range.range = Range.getBlankRange(win)
              range.range.setStart($start[0].childNodes[0], 2)
              range.range.collapse(true)
              range.select()
              range.keepRange(->)
              range.range = Range.getRangeFromSelection(win)
              range.insertHTML("<b></b>")
              expect(clean($start.html())).toEqual("st<b></b>art")

            it "keeps the range when not collapsed", ->
              range = new Range()
              spyOn(range, "getParentElements").andReturn([$start[0], $start[0]])
              range.range = Range.getBlankRange(win)
              range.range.setStart($start[0].childNodes[0], 2)
              range.range.setEnd($start[0].childNodes[0], 4)
              range.select()
              range.delete()
              expect(clean($start.html())).toEqual("stt")

            it "keeps the range when the function changes the range", ->
              fn = ->
                range = new Range()
                range.range = Range.getRangeFromElement($end[0])
                range.select()

              range = new Range()
              spyOn(range, "getParentElements").andReturn([$start[0], $start[0]])
              range.range = Range.getBlankRange(win)
              range.range.setStart($start[0].childNodes[0], 2)
              range.range.setEnd($start[0].childNodes[0], 4)
              range.select()

              range.keepRange(fn)
              range.delete()
              expect(clean($start.html())).toEqual("stt")

          describe "#moveBoundary", ->
            it "throws an error when the boundaries is not valid", ->
              range = new Range()
              range.range = Range.getRangeFromElement($start[0])
              expect(-> range.moveBoundary("test", $start[0])).toThrow()

            describe "element", ->
              beforeEach ->
                $veryEnd = $("<div>very end</div>").appendTo($editable)

              it "sets the start to the start of the element", ->
                range = new Range()
                range.range = Range.getRangeFromElement($end[0])
                range.moveBoundary("StartToStart", $start[0])
                range.range.collapse(true)
                range.select()
                range = new Range()
                range.range = Range.getRangeFromSelection(win)
                range.insertHTML("a")
                expect($start.html()).toEqual("astart")

              it "sets the start to the end of the element", ->
                range = new Range()
                range.range = Range.getRangeFromElement($end[0])
                range.moveBoundary("StartToEnd", $start[0])
                range.range.collapse(true)
                range.select()
                range = new Range()
                range.range = Range.getRangeFromSelection(win)
                range.insertHTML("a")
                expect($start.html()).toEqual("starta")

              it "sets the end to the start of the element", ->
                range = new Range()
                range.range = Range.getRangeFromElement($start[0])
                range.moveBoundary("EndToStart", $end[0])
                range.range.collapse(false)
                range.select()
                range = new Range()
                range.range = Range.getRangeFromSelection(win)
                range.insertHTML("a")
                expect($end.html()).toEqual("aend")

              it "sets the end to the end of the element", ->
                range = new Range()
                range.range = Range.getRangeFromElement($start[0])
                range.moveBoundary("EndToEnd", $end[0])
                range.range.collapse(false)
                range.select()
                range = new Range()
                range.range = Range.getRangeFromSelection(win)
                range.insertHTML("a")
                expect($end.html()).toEqual("enda")

            describe "textnode", ->
              startText = middleSpan = endText = null
              beforeEach ->
                $editable.html("start<span>middle</span>end")
                startText = $editable[0].childNodes[0]
                middleSpan = $editable[0].childNodes[1]
                endText = $editable[0].childNodes[2]

              it "sets the start to the start of the textnode", ->
                range = new Range()
                range.range = Range.getRangeFromElement(middleSpan)
                range.moveBoundary("StartToStart", startText)
                range.range.collapse(true)
                range.select()
                range = new Range()
                range.range = Range.getRangeFromSelection(win)
                range.insertHTML("a")
                expect(clean($editable.html())).toEqual("astart<span>middle</span>end")

              it "sets the start to the end of the textnode", ->
                range = new Range()
                range.range = Range.getRangeFromElement(middleSpan)
                range.moveBoundary("StartToEnd", startText)
                range.range.collapse(true)
                range.select()
                range = new Range()
                range.range = Range.getRangeFromSelection(win)
                range.insertHTML("a")
                expect(clean($editable.html())).toEqual("starta<span>middle</span>end")

              it "sets the end to the start of the textnode", ->
                range = new Range()
                range.range = Range.getRangeFromElement(middleSpan)
                range.moveBoundary("EndToStart", endText)
                range.range.collapse(false)
                range.select()
                range = new Range()
                range.range = Range.getRangeFromSelection(win)
                range.insertHTML("a")
                expect(clean($editable.html())).toEqual("start<span>middle</span>aend")

              it "sets the end to the end of the textnode", ->
                range = new Range()
                range.range = Range.getRangeFromElement(middleSpan)
                range.moveBoundary("EndToEnd", endText)
                range.range.collapse(false)
                range.select()
                range = new Range()
                range.range = Range.getRangeFromSelection(win)
                range.insertHTML("a")
                expect(clean($editable.html())).toEqual("start<span>middle</span>enda")

          describe "#insertNode", ->
            it "inserts the given element node", ->
              range = new Range()
              range.el = $editable
              range.range = Range.getBlankRange(win)
              range.range.selectNodeContents($start[0])
              range.range.collapse(true)
              range.insertNode($("<span/>")[0])
              expect($start.html()).toEqual("<span></span>start")

            it "inserts the given text node", ->
              range = new Range()
              range.el = $editable
              range.range = Range.getBlankRange(win)
              range.range.selectNodeContents($start[0])
              range.range.collapse(true)
              range.insertNode(doc.createTextNode("test"))
              expect($start.html()).toEqual("teststart")

            it "puts the selection after the node", ->
              text = doc.createTextNode("test")

              range = new Range()
              spyOn(range, "selectAfterElement")
              range.el = $editable
              range.range = Range.getBlankRange(win)
              range.range.selectNodeContents($start[0])
              range.range.collapse(true)
              range.insertNode(text)
              expect(range.selectAfterElement).toHaveBeenCalledWith(text)


          describe "#insertHTML", ->
            it "inserts the given HTML", ->
              range = new Range()
              range.range = Range.getBlankRange(win)
              range.range.selectNodeContents($start[0])
              range.range.collapse(true)
              range.insertHTML("<span><b>bold</b></span><div><ul><li>item</li></ul></div>")
              expect($start.html()).toEqual("<span><b>bold</b></span><div><ul><li>item</li></ul></div>start")

            it "puts the selection after the node", ->
              range = new Range()
              spyOn(range, "selectAfterElement")
              range.range = Range.getBlankRange(win)
              range.range.selectNodeContents($start[0])
              range.range.collapse(true)
              range.insertHTML("<span></span>")
              expect(range.selectAfterElement).toHaveBeenCalled()

          describe "#surroundContents", ->
            it "inserts the given HTML", ->
              range = new Range()
              range.el = $editable
              range.range = Range.getBlankRange(win)
              range.range.selectNodeContents($start[0])
              range.surroundContents($("<span/>")[0])
              expect($start.html()).toEqual("<span>start</span>")

            it "puts the selection after the node", ->
              $span = $("<span/>")

              range = new Range()
              spyOn(range, "selectAfterElement")
              range.el = $editable
              range.range = Range.getBlankRange(win)
              range.range.selectNodeContents($start[0])
              range.surroundContents($span[0])
              expect(range.selectAfterElement).toHaveBeenCalledWith($span[0])

          describe "#delete", ->
            $table = $tds = $after = range = null
            beforeEach ->
              $table = createElement("table").html("<tbody><tr><td>first cell</td><td>second cell</td></tr></tbody>").appendTo($editable)
              $tds = $table.find("td")
              $after = createElement("div").html("after").appendTo($editable)
              range = new Range()
              range.el = $editable[0]
              range.range = Range.getBlankRange(win)
              spyOn(range, "getParentElements")

            it "deletes the contents of the range when not selecting from a table cell", ->
              range.getParentElements.andReturn([$start[0], $start[0]])
              range.range.selectNodeContents($start[0])
              range.delete()
              expect($start.html()).toEqual("")

            it "deletes the contents of the range including the table", ->
              range.getParentElements.andReturn([$start[0], $after[0]])
              range.range.setStart($start[0].childNodes[0], 0)
              range.range.setEnd($after[0].childNodes[0], 5)
              range.delete()
              expect(clean($editable.html())).toEqual("<div></div>")

            it "does nothing when the start of the range starts in a table cell", ->
              html = $editable.html()
              range.getParentElements.andReturn([$tds[0], $after[0]])
              range.range.setStart($tds[0].childNodes[0], 0)
              range.range.setEnd($after[0].childNodes[0], 5)
              range.delete()
              expect(clean($editable.html())).toEqual(clean(html))

            it "does nothing when the end of the range ends in a table cell", ->
              html = $editable.html()
              range.getParentElements.andReturn([$start[0], $tds[0]])
              range.range.setStart($start[0].childNodes[0], 0)
              range.range.setEnd($tds[0].childNodes[0], 5)
              range.delete()
              expect(clean($editable.html())).toEqual(clean(html))

            it "does nothing when the start and end of the range are in different table cells", ->
              html = $editable.html()
              range.getParentElements.andReturn([$tds[0], $tds[1]])
              range.range.setStart($tds[0].childNodes[0], 0)
              range.range.setEnd($tds[1].childNodes[0], 5)
              range.delete()
              expect(clean($editable.html())).toEqual(clean(html))

            it "deletes the contents of the range when it starts and ends in the same table cell", ->
              html = $editable.html()
              range.getParentElements.andReturn([$tds[0], $tds[0]])
              range.range.setStart($tds[0].childNodes[0], 0)
              range.range.setEnd($tds[0].childNodes[0], 5)
              range.delete()
              expect($tds[0].innerHTML).toEqual(" cell")

            it "merges the nodes if the range starts and ends in different blocks", ->
              range.getParentElements.andReturn([$start[0], $after[0]])
              range.range.setStart($start[0].childNodes[0], 4)
              range.range.setEnd($after[0].childNodes[0], 2)
              range.select()
              range.delete()
              expect($editable.find("div").length).toEqual(1)
              expect($editable.find("div").html()).toEqual("starter")

            it "keeps the range", ->
              range.getParentElements.andReturn([$start[0], $end[0]])
              range.range.setStart($start[0].childNodes[0], 4)
              range.range.setEnd($end[0].childNodes[0], 2)
              range.select()
              range.delete()
              range.range = Range.getRangeFromSelection(win)
              range.insertHTML("<b></b>")
              expect($editable.find("div").html()).toEqual("star<b></b>d")

            it "keeps the range when there is no more content", ->
              $editable.html("<p>text</p>")
              $p = $editable.find("p")
              range.getParentElements.andReturn($p[0], $p[0])
              range.range.selectNodeContents($p[0])
              range.delete()
              range.range = Range.getRangeFromSelection(win)
              expect(range.range).not.toBeNull()
              range.insertHTML("<b></b>")
              if Browser.isWebkit
                expect(clean($editable.html())).toEqual("<p></p><b></b>")
              else
                expect(clean($editable.html())).toEqual("<p><b></b></p>")

            it "returns true if something was deleted", ->
              range.getParentElements.andReturn([$start[0], $start[0]])
              range.range.selectNodeContents($start[0])
              expect(range.delete()).toBeTruthy()

            it "returns false if nothing was deleted", ->
              html = $editable.html()
              range.getParentElements.andReturn([$tds[0], $after[0]])
              range.range.setStart($tds[0].childNodes[0], 0)
              range.range.setEnd($after[0].childNodes[0], 5)
              expect(range.delete()).toBeFalsy()

      describe "main document", ->
        tests(($container) -> document)

      describe "iframe document", ->
        # The first attempt at running the tests using an iframe was to
        # generate the iframe and run the tests through the load event.
        # e.g.  $(new IFrame(load: -> tests(@doc))).appendTo("body")
        # Unfortunately, when we're in describe(), document.body is null. We
        # don't have a body until beforeEach().
        #
        # The second attempt passes in a function that accepts a container and
        # returns a document. This function is run inside beforeEach() at the
        # beginning of the tests. Therefore, the body exists and the iframe can
        # be inserted. Unfortunately, because this runs in beforeEach(), we
        # can't call the tests from here. We can only insert the iframe. This
        # causes problems in Firefox and IE9 because the iframe does not load
        # immediately and therefore iframe.doc is null. Webkit is okay.
        #
        # A third attempt was not attempted because this is good enough for
        # now. We just want to make sure that Range works in an iframe and this
        # can be checked in Webkit. It will probably be rare that a Firefox or
        # IE9 only problem occurs. A possible solution that was thought of was
        # to create the iframe in each it() and run the test from the load
        # handler of the iframe. This would be similar to how we test IFrame in
        # iframe.spec.coffee. However, this would be costly to write because
        # each it() would need to be modified. If we see problems being
        # frequent, we can revisit this third attempt.
        if isWebkit
          tests(($container) ->
            iframe = new IFrame()
            $container.append(iframe)
            iframe.doc
          )

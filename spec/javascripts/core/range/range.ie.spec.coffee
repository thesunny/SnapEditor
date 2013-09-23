# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# NOTE: When checking an element's HTML, we use #toLowerCase() because IE
# returns the HTML tags as uppercase.
# NOTE: Unlike Range.W3C and Webkit, it is not easy to rerun the tests using an
# iframe. IE exhibits the same behaviour as Firefox where the iframe does not
# load immediately. This slight delay throws the iframe loading outside the
# scope of the test. For more information, go to the comments in the "iframe
# document" test.
unless hasW3CRanges
  require ["core/range/range.ie", "core/helpers"], (Module, Helpers) ->
    describe "Range.IE", ->
      Range = $editable = $start = $end = doc = win = null
      beforeEach ->
        $editable = addEditableFixture()
        $start = $('<div id="start">start</div>').appendTo($editable)
        $end = $('<div id="end">end</div>').appendTo($editable)
        doc = Helpers.getDocument($editable[0])
        win = Helpers.getWindow($editable[0])
        class Range
          doc: doc
          win: win
          createElement: (name) -> $(@doc.createElement(name))
          find: (selector) -> $(@doc).find(selector)
          getParentElements: ->
        Helpers.extend(Range, Module.static)
        Helpers.include(Range, Module.instance)
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

            actualRange = Range.getRangeFromSelection(win)
            expect(actualRange.text.length).toEqual(0)

            # Insert a span and ensure it is in the correct place.
            actualRange.pasteHTML("<span/>")
            expect(clean($start.html())).toEqual("<span></span>start")

          it "returns null when there is no selected range", ->
            win.document.selection.empty()
            expect(Range.getRangeFromSelection(win)).toBeNull()

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

        describe ".getParentElement", ->
          it "returns the parent from a TextRange", ->
            range = Range.getRangeFromElement($start[0])
            expect(Range.getParentElement(range)).toEqual($start[0])

          it "returns the parent from a ControlRange", ->
            $img = $('<img />').appendTo($editable)
            range = Range.getRangeFromElement($img[0])
            expect(Range.getParentElement(range)).toEqual($img[0])

      describe "instance functions", ->
        describe "#cloneRange", ->
          it "clones a textRange", ->
            range = new Range()
            range.range = Range.getRangeFromElement($start[0])
            clone = range.cloneRange()
            expect(clone.compareEndPoints("StartToStart", range.range)).toEqual(0)
            expect(clone.compareEndPoints("EndToEnd", range.range)).toEqual(0)

          it "clones a controlRange", ->
            $editable.html('<img src="/spec/javascripts/support/assets/images/stub.png" />')
            $img = $editable.find("img")
            range = new Range()
            range.range = Range.getRangeFromElement($img[0])
            clone = range.cloneRange()
            expect(clone.item(0)).toBe($img[0])

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
            range.range = Range.getRangeFromSelection(win)
            expect(range.isImageSelected()).toBeTruthy()

        describe "#isStartOfElement", ->
          $text = textnode = null
          beforeEach ->
            $text = $("<div>\n  \t#{Helpers.zeroWidthNoBreakSpace}\n \t\n    text</div>").appendTo($editable)
            textnode = $text[0].childNodes[0]

          it "returns true if range is at the start", ->
            range = new Range()
            range.range = Range.getBlankRange()
            # Place the selection at the beginning of "|text".
            range.range.findText("text")
            range.range.collapse(true)
            expect(range.isStartOfElement($text[0])).toBeTruthy()

          it "returns false if range is not at the start", ->
            range = new Range()
            range.range = Range.getBlankRange()
            # Place the selection in the middle of "te|xt".
            range.range.findText("xt")
            range.range.collapse(true)
            expect(range.isStartOfElement($text[0])).toBeFalsy()

          it "returns false if &nbsp; is before", ->
            $text.html("&nbsp;text")
            textnode = $text[0].childNodes[0]

            range = new Range()
            range.range = Range.getBlankRange()
            # Place the selection at the beginning of "|text".
            range.range.findText("text")
            range.range.collapse(true)
            expect(range.isStartOfElement($text[0])).toBeFalsy()

          it "returns false if an image is before", ->
            $text.html('<img src="/spec/javascripts/support/assets/images/stub.png" />text')
            textnode = $text[0].childNodes[1]

            range = new Range()
            range.range = Range.getBlankRange()
            # Place the selection at the beginning of "|text".
            range.range.findText("text")
            range.range.collapse(true)
            expect(range.isStartOfElement($text[0])).toBeFalsy()

        describe "#isEndOfElement", ->
          $text = textnode = null
          beforeEach ->
            $text = $("<div>text \t  \n\t      #{Helpers.zeroWidthNoBreakSpace}\n\n\t</div>").appendTo($editable)
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

          it "returns false if an image is after", ->
            $text.html('text<img src="/spec/javascripts/support/assets/images/stub.png" />')
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

        describe "#getText", ->
          it "returns the selected text when selecting only text", ->
            range = new Range()
            range.range = Range.getBlankRange()
            range.range.findText("start")
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

        describe "#selectElementContents", ->
          it "selects the contents of an inline element", ->
            $editable.html("before<b>bold</b>after")
            range = new Range()
            range.range = Range.getBlankRange()
            range.selectElementContents($editable.find("b")[0])

            actualRange = document.selection.createRange()
            expect(actualRange.parentElement()).toBe($editable.find("b")[0])
            expect(actualRange.text).toEqual("bold")

          it "selects the contents of a block element", ->
            $editable.html("before<div>block</div>after")
            range = new Range()
            range.range = Range.getBlankRange()
            range.selectElementContents($editable.find("div")[0])

            actualRange = document.selection.createRange()
            # IE8 selects the entire block instead of its contents.
            # IE7 behaves normally.
            if isIE8
              expect(actualRange.parentElement()).toBe($editable[0])
            else
              expect(actualRange.parentElement()).toBe($editable.find("div")[0])
            expect(clean(actualRange.text)).toEqual("block")

          it "select the contents of a link", ->
            $editable.html("before<a>link</a>after")
            range = new Range()
            range.range = Range.getBlankRange()
            range.selectElementContents($editable.find("a")[0])

            actualRange = document.selection.createRange()
            expect(actualRange.parentElement()).toBe($editable.find("a")[0])
            expect(actualRange.text).toEqual("link")

        describe "#selectEndOfElement", ->
          it "selects the end of the inside of the element when there is content", ->
            range = new Range()
            range.el = $editable[0]
            range.range = Range.getBlankRange()
            range.selectEndOfElement($start[0])

            actualRange = document.selection.createRange()
            actualRange.pasteHTML("<span></span>")
            expect(clean($start.html())).toEqual("start<span></span>")

          it "selects the end of the inside of the element when there is content with <br>", ->
            $start.html("start<br/><br/>break")

            range = new Range()
            range.el = $editable[0]
            range.range = Range.getBlankRange()
            range.selectEndOfElement($start[0])

            actualRange = document.selection.createRange()
            actualRange.pasteHTML("<span></span>")
            expect(clean($start.html())).toEqual("start<br><br>break<span></span>")

          it "selects the end of the inside of the cell when there is content", ->
            $table = $('<table><tbody><tr><td id="td">before</td><td>after</td></tr></tbody></table>').appendTo($editable)
            $td = $("#td")

            range = new Range()
            range.range = Range.getBlankRange()
            range.selectEndOfElement($td[0])

            actualRange = document.selection.createRange()
            actualRange.pasteHTML("<span></span>")
            expect(clean($td.html())).toEqual("before<span></span>")

          it "selects the end of the inside of the cell when there is content with <br>", ->
            $table = $('<table><tbody><tr><td id="td">before<br/><br/>break</td><td>after</td></tr></tbody></table>').appendTo($editable)
            $td = $("#td")

            range = new Range()
            range.range = Range.getBlankRange()
            range.selectEndOfElement($td[0])

            actualRange = document.selection.createRange()
            actualRange.pasteHTML("<span></span>")
            expect(clean($td.html())).toEqual("before<br><br>break<span></span>")

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
            range.range = Range.getRangeFromSelection(win)
            range.insertHTML("<b></b>")
            expect(clean($start.html())).toEqual("s<b></b>tart")

          it "keeps the range when not collapsed", ->
            range = new Range()
            spyOn(range, "getParentElements").andReturn([$start[0], $start[0]])
            range.range = Range.getBlankRange()
            range.range.findText("tar")
            range.select()
            range.keepRange(->)
            range.delete()
            expect(clean($start.html())).toEqual("st")

          it "keeps the range when the function changes the range", ->
            fn = ->
              range = new Range()
              range.range = Range.getRangeFromElement($end[0])
              range.select()

            range = new Range()
            spyOn(range, "getParentElements").andReturn([$start[0], $start[0]])
            range.range = Range.getBlankRange()
            range.range.findText("tar")
            range.select()

            range.keepRange(fn)
            range.delete()
            expect(clean($start.html())).toEqual("st")

          it "keeps the range when selecting an image", ->
            $editable.html('<img src="/spec/javascripts/support/assets/images/stub.png" /><div>after</div>')
            $img = $editable.find("img")
            $div = $editable.find("div")
            range = new Range()
            spyOn(range, "getParentElements").andReturn([$img[0], $img[0]])
            range.range = Range.getRangeFromElement($img[0])
            range.select()
            range.keepRange(->
              r = new Range()
              r.range = Range.getRangeFromElement($div[0])
              r.select()
            )
            range.delete()
            expect(clean($editable.html())).toEqual("<div>after</div>")

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
            spyOn(range, "insertHTML")
            range.insertNode($("<span/>")[0])
            expect(range.insertHTML).toHaveBeenCalledWith("<SPAN></SPAN>")

          it "inserts the given text node", ->
            range = new Range()
            spyOn(range, "insertHTML")
            range.insertNode(document.createTextNode("test"))
            expect(range.insertHTML).toHaveBeenCalledWith("test")

        describe "#insertHTML", ->
          describe "collapsed", ->
            range = null
            beforeEach ->
              range = new Range()
              range.range = Range.getRangeFromElement($start[0])
              range.range.collapse(true)

            it "inserts elements", ->
              range.insertHTML("<span><b>bold</b></span><div><ul><li>item</li></ul></div>")
              expect(clean($start.html())).toEqual("<span><b>bold</b></span><div><ul><li>item</li></ul></div>start")

            it "inserts text", ->
              range.insertHTML("test")
              expect(clean($start.html())).toEqual("teststart")

            it "puts the selection after the HTML", ->
              range.insertHTML("<span></span>")
              actualRange = document.selection.createRange()
              actualRange.pasteHTML("<b></b>")
              expect(clean($start.html())).toEqual("<span></span><b></b>start")

          describe "not collapsed", ->
            range = null
            beforeEach ->
              range = new Range()
              range.range = Range.getBlankRange()
              range.range.findText("start")

            it "inserts elements", ->
              range.insertHTML("<span></span>")
              expect(clean($start.html())).toEqual("<span></span>")

            it "inserts text", ->
              range.insertHTML("test")
              expect(clean($start.html())).toEqual("test")

            it "puts the selection after the text", ->
              range.insertHTML("test")
              actualRange = document.selection.createRange()
              actualRange.pasteHTML("<b></b>")
              expect(clean($start.html())).toEqual("test<b></b>")

            it "puts the selection after the elements", ->
              range.insertHTML("<span>test</span>")
              actualRange = document.selection.createRange()
              actualRange.pasteHTML("<b></b>")
              expect(clean($start.html())).toEqual("<span>test<b></b></span>")

          describe "image", ->
            range = null
            beforeEach ->
              $editable.html('before<img src="/spec/javascripts/support/assets/images/stub.png" />after')
              $img = $editable.find("img")
              range = new Range()
              range.range = Range.getRangeFromElement($img[0])

            it "inserts elements", ->
              range.insertHTML("<span></span>")
              expect(clean($editable.html())).toEqual("before<span></span>after")

            it "inserts text", ->
              range.insertHTML("test")
              expect(clean($editable.html())).toEqual("beforetestafter")

            it "puts the selection after the text", ->
              range.insertHTML("test")
              actualRange = document.selection.createRange()
              actualRange.pasteHTML("<b></b>")
              expect(clean($editable.html())).toEqual("beforetest<b></b>after")

        describe "#surroundContents", ->
          it "inserts the given HTML", ->
            range = new Range()
            spyOn(range, "insertNode")
            range.range = Range.getBlankRange()
            range.range.findText("start")
            range.surroundContents($("<span/>")[0])

            expect(range.insertNode).toHaveBeenCalled()
            # Check the first argument to the first call to #insertNode.
            # We're expecting the argument to be the node "<span>start</span>".
            el = range.insertNode.argsForCall[0][0]
            expect(el.tagName).toEqual("SPAN")
            expect(el.innerHTML).toEqual("start")

          it "inserts the given HTML when an image is selected", ->
            $editable.html('<img src="/spec/javascripts/support/assets/images/stub.png" />')
            $img = $editable.find("img")
            range = new Range()
            spyOn(range, "insertNode")
            range.range = Range.getRangeFromElement($img[0])
            range.surroundContents($("<span/>")[0])

            expect(range.insertNode).toHaveBeenCalled()
            # Check the first argument to the first call to #insertNode.
            # We're expecting the argument to be the node "<span>start</span>".
            el = range.insertNode.argsForCall[0][0]
            expect(el.tagName).toEqual("SPAN")
            if isIE7
              # IE7 changes the path to a full URL.
              expect(clean(el.innerHTML)).toMatch('<img src=(.*)/spec/javascripts/support/assets/images/stub.png>')
            else
              expect(clean(el.innerHTML)).toEqual('<img src=/spec/javascripts/support/assets/images/stub.png>')

        describe "#delete", ->
          $table = $tds = $after = range = null
          beforeEach ->
            $table = $("<table><tbody><tr><td>first cell</td><td>second cell</td></tr></tbody></table>").appendTo($editable)
            $tds = $table.find("td")
            $after = $("<div>after</div>").appendTo($editable)
            range = new Range()
            range.el = $editable[0]
            range.range = Range.getBlankRange()
            spyOn(range, "getParentElements")

          it "deletes an image", ->
            $editable.html('before<img src="/spec/javascripts/support/assets/images/stub.png" />after')
            $img = $editable.find("img")
            range.getParentElements.andReturn([$img[0], $img[0]])
            range.range = Range.getRangeFromElement($editable.find("img")[0])
            range.select()
            range.delete()
            expect(clean($editable.html())).toEqual("beforeafter")

          it "deletes the contents of the range when not selecting from a table cell", ->
            range.getParentElements.andReturn([$start[0], $start[0]])
            range.range.findText("start")
            range.delete()
            expect($start.html()).toEqual("")

          it "deletes the contents of the range including the table", ->
            range.getParentElements.andReturn([$start[0], $after[0]])
            range.range.findText("start")
            endRange = Range.getBlankRange()
            endRange.findText("after")
            range.range.setEndPoint("EndToEnd", endRange)
            range.delete()
            # NOTE: IE leaves a &nbsp; instead of empty.
            expect(clean($editable.html())).toEqual("<div id=start>&nbsp;</div>")

          it "does nothing when the start of the range starts in a table cell", ->
            html = $editable.html()
            range.getParentElements.andReturn([$tds[0], $after[0]])
            range.range.findText("first")
            endRange = Range.getBlankRange()
            endRange.findText("after")
            range.range.setEndPoint("EndToEnd", endRange)
            range.delete()
            expect(clean($editable.html())).toEqual(clean(html))

          it "does nothing when the end of the range ends in a table cell", ->
            html = $editable.html()
            range.getParentElements.andReturn([$start[0], $tds[0]])
            range.range.findText("start")
            endRange = Range.getBlankRange()
            endRange.findText("first")
            range.range.setEndPoint("EndToEnd", endRange)
            range.delete()
            expect(clean($editable.html())).toEqual(clean(html))

          it "does nothing when the start and end of the range are in different table cells", ->
            html = $editable.html()
            range.getParentElements.andReturn([$tds[0], $tds[1]])
            range.range.findText("first")
            endRange = Range.getBlankRange()
            endRange.findText("second")
            range.range.setEndPoint("EndToEnd", endRange)
            range.delete()
            expect(clean($editable.html())).toEqual(clean(html))

          it "deletes the contents of the range when it starts and ends in the same table cell", ->
            html = $editable.html()
            range.getParentElements.andReturn([$tds[0], $tds[0]])
            range.range.findText("first")
            range.delete()
            # NOTE: IE changes the space to &nbsp;
            expect($tds[0].innerHTML).toEqual("&nbsp;cell")

          it "merges the nodes if the range starts and ends in different blocks", ->
            range.getParentElements.andReturn([$start[0], $after[0]])
            range.range = Range.getBlankRange()
            range.range.findText("star")
            range.range.collapse(false)
            endRange = Range.getBlankRange()
            endRange.findText("af")
            range.range.setEndPoint("EndToEnd", endRange)
            range.select()
            range.delete()
            expect($editable.find("div").length).toEqual(1)
            expect($editable.find("div").html()).toEqual("starter")

          it "keeps the range", ->
            range.getParentElements.andReturn([$start[0], $end[0]])
            range.range.findText("star")
            range.range.collapse(false)
            endRange = Range.getBlankRange()
            endRange.findText("en")
            range.range.setEndPoint("EndToEnd", endRange)
            range.select()
            range.delete()
            range = Range.getRangeFromSelection(win)
            range.pasteHTML("<b></b>")
            expect(clean($editable.find("div").html())).toEqual("star<b></b>d")

          it "keeps the range after deleting an image", ->
            $editable.html('before<img src="/spec/javascripts/support/assets/images/stub.png" />after')
            $img = $editable.find("img")
            range.getParentElements.andReturn([$img[0], $img[0]])
            range.range = Range.getRangeFromElement($editable.find("img")[0])
            range.select()
            range.delete()
            range = Range.getRangeFromSelection(win)
            range.pasteHTML("<b></b>")
            expect(clean($editable.html())).toEqual("before<b></b>after")

          it "keeps the range valid after deleting", ->
            $editable.html('before<img src="/spec/javascripts/support/assets/images/stub.png" />after')
            $img = $editable.find("img")
            range.getParentElements.andReturn([$img[0], $img[0]])
            range.range = Range.getRangeFromElement($editable.find("img")[0])
            range.select()
            range.delete()
            range.insertHTML("<b></b>")
            expect(clean($editable.html())).toEqual("before<b></b>after")

          it "returns true if something was deleted", ->
            range.getParentElements.andReturn([$start[0], $start[0]])
            range.range.findText("start")
            expect(range.delete()).toBeTruthy()

          it "returns false if nothing was deleted", ->
            html = $editable.html()
            range.getParentElements.andReturn([$tds[0], $after[0]])
            range.range.findText("first")
            endRange = Range.getBlankRange()
            endRange.findText("after")
            range.range.setEndPoint("EndToEnd", endRange)
            expect(range.delete()).toBeFalsy()

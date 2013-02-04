# TODO: The atomic plugin requires the ability to override the delete in
# certain scenarios. However, because there is no events infrastructure in
# place, we have to add the atomic plugin deletion code here, which is not the
# correct place. However, this is the only way it will work. This is a hack
# for now. When the events infrastructure is in place, we should move the
# atomic deletion code back to the atomic plugin. The original file before the
# atomic deletion code was added can be found at
# erase_handler.spec.before_atomic.coffee.
require ["jquery.custom", "plugins/erase_handler/erase_handler", "core/range", "core/helpers"], ($, Handler, Range, Helpers) ->
  describe "EraseHandler", ->
    $editable = $h1 = $p = handler = null
    beforeEach ->
      $editable = addEditableFixture()
      $h1 = $("<h1>header heading</h1>").appendTo($editable)
      $p = $("<p>some text</p>").appendTo($editable)
      handler = new Handler()
      handler.api =
        el: $editable[0]
        getRange: (el) -> new Range($editable[0], el or window)
        select: (el) -> @getRange(el).select()
        config: atomic: classname: "atomic"
      Helpers.delegate(handler.api, "getRange()", "delete", "keepRange", "collapse", "isCollapsed")

    afterEach ->
      $editable.remove()

    if isWebkit
      describe "#handleCursor", ->
        describe "delete", ->
          event = null
          beforeEach ->
            event = which:46, type: "keydown", preventDefault: ->

          it "merges the nodes together", ->
            range = new Range($editable[0])
            range.range.selectNodeContents($h1[0])
            range.collapse(false)
            range.select()

            handler.handleCursor(event)
            expect($editable.html()).toEqual("<h1>header headingsome text</h1>")

            range = new Range($editable[0], window)
            range.insert("<b></b>")
            expect($h1.html()).toEqual("header heading<b></b>some text")

          it "does not merge the nodes together when the next node is a table", ->
            $("<table><tbody><tr><td>text</td></tr></tbody</table>").insertAfter($h1)
            html = $editable.html()

            range = new Range($editable[0])
            range.range.selectNodeContents($h1[0])
            range.collapse(false)
            range.select()

            handler.handleCursor(event)
            expect($editable.html()).toEqual(html)

            range = new Range($editable[0], window)
            range.insert("<b></b>")
            expect($h1.html()).toEqual("header heading<b></b>")

          it "merges the first list item into the node when the next node is a list", ->
            $ul = $("<ul><li>item</li></ul>").insertAfter($h1)

            range = new Range($editable[0])
            range.range.selectNodeContents($h1[0])
            range.collapse(false)
            range.select()

            handler.handleCursor(event)
            expect($h1.html()).toEqual("header headingitem")
            expect($editable.find("ul").length).toEqual(0)

            range = new Range($editable[0], window)
            range.insert("<b></b>")
            expect($h1.html()).toEqual("header heading<b></b>item")

          it "deletes the next hr", ->
            $hr = $("<hr/>").insertAfter($h1)

            range = new Range($editable[0])
            range.range.selectNodeContents($h1[0])
            range.collapse(false)
            range.select()

            handler.handleCursor(event)
            expect($editable.find("hr").length).toEqual(0)

        describe "backspace", ->
          event = null
          beforeEach ->
            event = which: 8, type: "keydown", preventDefault: ->

          it "merges the nodes together", ->
            range = new Range($editable[0])
            range.range.selectNodeContents($p[0])
            range.collapse(true)
            range.select()

            handler.handleCursor(event)
            expect($editable.html()).toEqual("<h1>header headingsome text</h1>")

            range = new Range($editable[0], window)
            range.insert("<b></b>")
            expect($h1.html()).toEqual("header heading<b></b>some text")

          it "does not merge the nodes together when the previous node is a table", ->
            $("<table><tbody><tr><td>text</td></tr></tbody</table>").insertBefore($p)
            html = $editable.html()

            range = new Range($editable[0])
            range.range.selectNodeContents($p[0])
            range.collapse(true)
            range.select()

            handler.handleCursor(event)
            expect($editable.html()).toEqual(html)

            range = new Range($editable[0], window)
            range.insert("<b></b>")
            expect($p.html()).toEqual("<b></b>some text")

          it "does not merge the nodes together when the previous node is a list", ->
            $ul = $("<ul><li>item</li></ul>").insertBefore($p)
            $li = $ul.find("li")

            range = new Range($editable[0])
            range.range.selectNodeContents($p[0])
            range.collapse(true)
            range.select()

            handler.handleCursor(event)
            expect($li.html()).toEqual("itemsome text")
            expect($editable.find("p").length).toEqual(0)

            range = new Range($editable[0], window)
            range.insert("<b></b>")
            expect($li.html()).toEqual("item<b></b>some text")

          it "deletes the previous hr", ->
            $hr = $("<hr/>").insertBefore($p)

            range = new Range($editable[0])
            range.range.selectNodeContents($p[0])
            range.collapse(true)
            range.select()

            handler.handleCursor(event)
            expect($editable.find("hr").length).toEqual(0)

    describe "#deleteAtomicElement", ->
      e = null
      beforeEach ->
        e = preventDefault: ->
        spyOn(e, "preventDefault")

      it "returns false when the range is collapsed", ->
        spyOn(handler.api, "isCollapsed").andReturn(false)
        expect(handler.deleteAtomicElement(e, "delete")).toBeFalsy()

      describe "delete", ->
        range = null
        beforeEach ->
          range = new Range($editable[0])

        describe "next sibling exists", ->
          it "does nothing and returns false when the sibling is not an element", ->
            $editable.html("<span>element</span>text")
            $span = $editable.find("span")
            if hasW3CRanges
              range.range.setStart($span[0].childNodes[0], 0)
              range.range.setEnd($span[0].childNodes[0], 7)
            else
              range.range.findText("element")
            range.collapse(false)
            range.select()
            expect(handler.deleteAtomicElement(e, "delete")).toBeFalsy()
            expect(e.preventDefault).not.toHaveBeenCalled()

          it "does nothing and returns false when the sibling is not an atomic element", ->
            $editable.html("text<span>element</span>")
            text = $editable[0].firstChild
            if hasW3CRanges
              range.range.setStart(text, 0)
              range.range.setEnd(text, 4)
            else
              range.range.findText("text")
            range.collapse(false)
            range.select()
            expect(handler.deleteAtomicElement(e, "delete")).toBeFalsy()
            expect(e.preventDefault).not.toHaveBeenCalled()

          it "deletes the atomic element and returns true when the sibling is an atomic element", ->
            $editable.html('text<span class="atomic">element</span>')
            text = $editable[0].firstChild
            if hasW3CRanges
              range.range.setStart(text, 0)
              range.range.setEnd(text, 4)
            else
              range.range.findText("text")
            range.collapse(false)
            range.select()
            expect(handler.deleteAtomicElement(e, "delete")).toBeTruthy()
            expect(e.preventDefault).toHaveBeenCalled()
            expect($editable.html()).toEqual("text")

        describe "next sibling doesn't exist", ->
          it "does nothing and returns false when the parent has no next sibling", ->
            $editable.html("<div>text</div>")
            $div = $editable.find("div")
            if hasW3CRanges
              range.range.setStart($div[0].childNodes[0], 4)
              range.range.setEnd($div[0].childNodes[0], 4)
            else
              range.range.findText("text")
            range.collapse(false)
            range.select()
            expect(handler.deleteAtomicElement(e, "delete")).toBeFalsy()
            expect(e.preventDefault).not.toHaveBeenCalled()

          it "does nothing and returns false when the parent's sibling is not an atomic element", ->
            $editable.html("<div>text</div><div>not atomic</div>")
            $div = $editable.find("div")
            if hasW3CRanges
              range.range.setStart($div[0].childNodes[0], 4)
              range.range.setEnd($div[0].childNodes[0], 4)
            else
              range.range.findText("text")
            range.collapse(false)
            range.select()
            expect(handler.deleteAtomicElement(e, "delete")).toBeFalsy()
            expect(e.preventDefault).not.toHaveBeenCalled()

          it "deletes the atomic element and returns true when the parent's sibling is an atomic element", ->
            $editable.html('<div>text</div><div class="atomic">not atomic</div>')
            $div = $editable.find("div")
            if hasW3CRanges
              range.range.setStart($div[0].childNodes[0], 4)
              range.range.setEnd($div[0].childNodes[0], 4)
            else
              range.range.findText("text")
            range.collapse(false)
            range.select()
            expect(handler.deleteAtomicElement(e, "delete")).toBeTruthy()
            expect(e.preventDefault).toHaveBeenCalled()
            expect(clean($editable.html())).toEqual("<div>text</div>")

      describe "backspace", ->
        range = null
        beforeEach ->
          range = new Range($editable[0])

        describe "next sibling exists", ->
          it "does nothing and returns false when the sibling is not an element", ->
            $editable.html("text<span>element</span>")
            $span = $editable.find("span")
            if hasW3CRanges
              range.range.setStart($span[0].childNodes[0], 0)
              range.range.setEnd($span[0].childNodes[0], 7)
            else
              range.range.findText("element")
            range.collapse(true)
            range.select()
            expect(handler.deleteAtomicElement(e, "backspace")).toBeFalsy()
            expect(e.preventDefault).not.toHaveBeenCalled()

          it "does nothing and returns false when the sibling is not an atomic element", ->
            # Add a zero width no-break space because when placing the cursor
            # before text that has a previous sibling element, Webkit moves
            # the cursor to the end of the inside of the sibling element.
            $editable.html("<span>element</span>#{Helpers.zeroWidthNoBreakSpace}text")
            text = $editable[0].lastChild
            if hasW3CRanges
              range.range.setStart(text, 1)
              range.range.setEnd(text, 4)
            else
              range.range.findText("text")
            range.collapse(true)
            range.select()
            expect(handler.deleteAtomicElement(e, "backspace")).toBeFalsy()
            expect(e.preventDefault).not.toHaveBeenCalled()

          it "deletes the atomic element and returns true when the sibling is an atomic element", ->
            # Add a zero width no-break space because when placing the cursor
            # before text that has a previous sibling element, Webkit moves
            # the cursor to the end of the inside of the sibling element.
            $editable.html("<span class=\"atomic\">element</span>#{Helpers.zeroWidthNoBreakSpace}text")
            text = $editable[0].lastChild
            if hasW3CRanges
              range.range.setStart(text, 1)
              range.range.setEnd(text, 4)
            else
              range.range.findText("text")
            range.collapse(true)
            range.select()
            expect(handler.deleteAtomicElement(e, "backspace")).toBeTruthy()
            expect(e.preventDefault).toHaveBeenCalled()
            expect(clean($editable.html())).toEqual("text")

        describe "next sibling doesn't exist", ->
          it "does nothing and returns false when the parent has no next sibling", ->
            $editable.html("<div>text</div>")
            $div = $editable.find("div")
            if hasW3CRanges
              range.range.setStart($div[0].childNodes[0], 4)
              range.range.setEnd($div[0].childNodes[0], 4)
            else
              range.range.findText("text")
            range.collapse(true)
            range.select()
            expect(handler.deleteAtomicElement(e, "backspace")).toBeFalsy()
            expect(e.preventDefault).not.toHaveBeenCalled()

          it "does nothing and returns false when the parent's sibling is not an atomic element", ->
            $editable.html("<div>not atomic</div><div>text</div>")
            $div = $editable.find("div")
            if hasW3CRanges
              range.range.setStart($div[1].childNodes[0], 4)
              range.range.setEnd($div[1].childNodes[0], 4)
            else
              range.range.findText("text")
            range.collapse(true)
            range.select()
            expect(handler.deleteAtomicElement(e, "backspace")).toBeFalsy()
            expect(e.preventDefault).not.toHaveBeenCalled()

          it "deletes the atomic element and returns true when the parent's sibling is an atomic element", ->
            $editable.html('<div class="atomic">not atomic</div><div>text</div>')
            $div = $editable.find("div")
            if hasW3CRanges
              range.range.setStart($div[1].childNodes[0], 0)
              range.range.setEnd($div[1].childNodes[0], 4)
            else
              range.range.findText("text")
            range.collapse(true)
            range.select()
            expect(handler.deleteAtomicElement(e, "backspace")).toBeTruthy()
            expect(e.preventDefault).toHaveBeenCalled()
            expect(clean($editable.html())).toEqual("<div>text</div>")


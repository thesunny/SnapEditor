# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "plugins/erase_handler/erase_handler", "core/range", "core/helpers"], ($, Handler, Range, Helpers) ->
  describe "EraseHandler", ->
    $editable = $h1 = $p = api = null
    beforeEach ->
      $editable = addEditableFixture()
      $h1 = $("<h1>header heading</h1>").appendTo($editable)
      $p = $("<p>some text</p>").appendTo($editable)
      api = $.extend($("<div/>"),
        el: $editable[0]
        getRange: (el) -> new Range($editable[0], el or window)
        select: (el) -> @getRange(el).select()
        config: eraseHandler: delete: [".delete"]
      )
      Handler.api = api
      Helpers.delegate(api, "getRange()", "delete", "keepRange", "collapse", "isCollapsed")

    afterEach ->
      $editable.remove()

    if isWebkit
      describe "#merge", ->
        describe "delete", ->
          event = null
          beforeEach ->
            event = which:46, type: "keydown", preventDefault: ->

          it "merges the nodes together", ->
            range = new Range($editable[0])
            range.range.selectNodeContents($h1[0])
            range.collapse(false)
            range.select()

            Handler.merge(event)
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

            Handler.merge(event)
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

            Handler.merge(event)
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

            Handler.merge(event)
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

            Handler.merge(event)
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

            Handler.merge(event)
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

            Handler.merge(event)
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

            Handler.merge(event)
            expect($editable.find("hr").length).toEqual(0)

    describe "#shouldDelete", ->
      it "returns true for a <hr>", ->
        expect(Handler.shouldDelete($("<hr/>")[0])).toBeTruthy()

      it "returns true for a class to be deleted", ->
        expect(Handler.shouldDelete($("<div>").addClass("delete")[0])).toBeTruthy()

      it "returns false when it should not be deleted", ->
        expect(Handler.shouldDelete($("<p/>")[0])).toBeFalsy()

    describe "#delete", ->
      e = null
      beforeEach ->
        e = preventDefault: ->
        spyOn(e, "preventDefault")

      it "returns false when the range is collapsed", ->
        spyOn(api, "isCollapsed").andReturn(false)
        expect(Handler.delete(e, "delete")).toBeFalsy()

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
            expect(Handler.delete(e, "delete")).toBeFalsy()
            expect(e.preventDefault).not.toHaveBeenCalled()

          it "does nothing and returns false when the sibling should not be deleted", ->
            $editable.html("text<span>element</span>")
            text = $editable[0].firstChild
            if hasW3CRanges
              range.range.setStart(text, 0)
              range.range.setEnd(text, 4)
            else
              range.range.findText("text")
            range.collapse(false)
            range.select()
            expect(Handler.delete(e, "delete")).toBeFalsy()
            expect(e.preventDefault).not.toHaveBeenCalled()

          it "deletes the element and returns true when the sibling should be deleted", ->
            $editable.html('text<span class="delete">element</span>')
            text = $editable[0].firstChild
            if hasW3CRanges
              range.range.setStart(text, 0)
              range.range.setEnd(text, 4)
            else
              range.range.findText("text")
            range.collapse(false)
            range.select()
            expect(Handler.delete(e, "delete")).toBeTruthy()
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
            expect(Handler.delete(e, "delete")).toBeFalsy()
            expect(e.preventDefault).not.toHaveBeenCalled()

          it "does nothing and returns false when the parent's sibling should not be deleted", ->
            $editable.html("<div>text</div><div>don't delete me</div>")
            $div = $editable.find("div")
            if hasW3CRanges
              range.range.setStart($div[0].childNodes[0], 4)
              range.range.setEnd($div[0].childNodes[0], 4)
            else
              range.range.findText("text")
            range.collapse(false)
            range.select()
            expect(Handler.delete(e, "delete")).toBeFalsy()
            expect(e.preventDefault).not.toHaveBeenCalled()

          it "deletes the element and returns true when the parent's sibling should be deleted", ->
            $editable.html('<div>text</div><div class="delete">delete me</div>')
            $div = $editable.find("div")
            if hasW3CRanges
              range.range.setStart($div[0].childNodes[0], 4)
              range.range.setEnd($div[0].childNodes[0], 4)
            else
              range.range.findText("text")
            range.collapse(false)
            range.select()
            expect(Handler.delete(e, "delete")).toBeTruthy()
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
            expect(Handler.delete(e, "backspace")).toBeFalsy()
            expect(e.preventDefault).not.toHaveBeenCalled()

          it "does nothing and returns false when the sibling should be deleted", ->
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
            expect(Handler.delete(e, "backspace")).toBeFalsy()
            expect(e.preventDefault).not.toHaveBeenCalled()

          it "deletes the element and returns true when the sibling should be deleted", ->
            # Add a zero width no-break space because when placing the cursor
            # before text that has a previous sibling element, Webkit moves
            # the cursor to the end of the inside of the sibling element.
            $editable.html("<span class=\"delete\">element</span>#{Helpers.zeroWidthNoBreakSpace}text")
            text = $editable[0].lastChild
            if hasW3CRanges
              range.range.setStart(text, 1)
              range.range.setEnd(text, 4)
            else
              range.range.findText("text")
            range.collapse(true)
            range.select()
            expect(Handler.delete(e, "backspace")).toBeTruthy()
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
            expect(Handler.delete(e, "backspace")).toBeFalsy()
            expect(e.preventDefault).not.toHaveBeenCalled()

          it "does nothing and returns false when the parent's sibling should not be deleted", ->
            $editable.html("<div>don't delete me</div><div>text</div>")
            $div = $editable.find("div")
            if hasW3CRanges
              range.range.setStart($div[1].childNodes[0], 4)
              range.range.setEnd($div[1].childNodes[0], 4)
            else
              range.range.findText("text")
            range.collapse(true)
            range.select()
            expect(Handler.delete(e, "backspace")).toBeFalsy()
            expect(e.preventDefault).not.toHaveBeenCalled()

          it "deletes the element and returns true when the parent's sibling should be deleted", ->
            $editable.html('<div class="delete">delete me</div><div>text</div>')
            $div = $editable.find("div")
            if hasW3CRanges
              range.range.setStart($div[1].childNodes[0], 0)
              range.range.setEnd($div[1].childNodes[0], 4)
            else
              range.range.findText("text")
            range.collapse(true)
            range.select()
            expect(Handler.delete(e, "backspace")).toBeTruthy()
            expect(e.preventDefault).toHaveBeenCalled()
            expect(clean($editable.html())).toEqual("<div>text</div>")


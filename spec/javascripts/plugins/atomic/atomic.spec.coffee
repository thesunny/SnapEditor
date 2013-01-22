require ["jquery.custom", "plugins/atomic/atomic", "core/range", "core/helpers", "core/browser"], ($, Atomic, Range, Helpers, Browser) ->
  describe "Atomic", ->
    $editable = $start = $end = $middle = atomic = null
    beforeEach ->
      $editable = addEditableFixture()
      $editable.html('<div>start</div><div>middle</div><div>end</div>')
      $start = $($editable.find("div")[0])
      $middle = $($editable.find("div")[1])
      $end = $($editable.find("div")[2])
      atomic = new Atomic()
      atomic.api = $("<div/>")
      atomic.api.config =
        atomic:
          classnames: ["atomic", "widget"]
      atomic.api.el = $editable[0]
      atomic.api.getRange = (el) -> new Range($editable[0], el or window)
      atomic.api.getBlankRange = -> new Range($editable[0])
      atomic.api.select = (el) -> @getRange(el).select()
      atomic.api.getDefaultBlock = -> $("<p>")[0]
      atomic.api.createTextNode = (text) -> document.createTextNode(text)
      Helpers.delegate(atomic.api, "getRange()", "collapse")
      Helpers.delegate(atomic.api, "getBlankRange()", "selectEndOfElement")

    afterEach ->
      $editable.remove()

    describe "#getClassnamesSelector", ->
      it "returns the correct selector", ->
        expect(atomic.getClassnamesSelector()).toEqual(".atomic, .widget")

    describe "#getSibling", ->
      beforeEach ->
        spyOn(atomic, "insertSibling").andReturn("sibling")

      it "returns the previous sibling when it exists and is not atomic", ->
        expect(atomic.getSibling("previous", $middle[0])).toBe($start[0])

      it "returns the next sibling when it exists and is not atomic", ->
        expect(atomic.getSibling("next", $middle[0])).toBe($end[0])

      it "returns a new previous sibling when the previous sibling doesn't exist", ->
        expect(atomic.getSibling("previous", $start[0])).toEqual("sibling")
        expect(atomic.insertSibling).toHaveBeenCalledWith("before", $start[0])

      it "returns a new next sibling when the next sibling doesn't exist", ->
        expect(atomic.getSibling("next", $end[0])).toEqual("sibling")
        expect(atomic.insertSibling).toHaveBeenCalledWith("after", $end[0])

      it "returns a new previous sibling when the previous sibling is atomic", ->
        $start.addClass("atomic")
        expect(atomic.getSibling("previous", $start[0])).toEqual("sibling")
        expect(atomic.insertSibling).toHaveBeenCalledWith("before", $start[0])

      it "returns a new next sibling when the next sibling is atomic", ->
        $end.addClass("atomic")
        expect(atomic.getSibling("next", $end[0])).toEqual("sibling")
        expect(atomic.insertSibling).toHaveBeenCalledWith("after", $end[0])

    describe "#insertSibling", ->
      describe "block", ->
        it "inserts the default block before the element", ->
          atomic.insertSibling("before", $middle[0])
          expect($middle.prev().tagName()).toEqual("p")

        it "inserts the default block after the element", ->
          atomic.insertSibling("after", $middle[0])
          expect($middle.next().tagName()).toEqual("p")

        it "returns the inserted sibling", ->
          sibling = atomic.insertSibling("before", $middle[0])
          expect(sibling).toBe($middle.prev()[0])

      describe "inline", ->
        $span = null
        beforeEach ->
          $editable.html("<span>test</span>")
          $span = $editable.find("span")

        it "inserts a zero width no-break space before the element", ->
          atomic.insertSibling("before", $span[0])
          expect($span[0].previousSibling.nodeValue).toEqual(Helpers.zeroWidthNoBreakSpaceUnicode)

        it "inserts a zero width no-break space after the element", ->
          atomic.insertSibling("after", $span[0])
          expect($span[0].nextSibling.nodeValue).toEqual(Helpers.zeroWidthNoBreakSpaceUnicode)

        it "returns the inserted sibling", ->
          sibling = atomic.insertSibling("before", $span[0])
          expect(sibling).toBe($span[0].previousSibling)

    describe "#moveCollapsedRange", ->
      describe "block", ->
        beforeEach ->
          atomic.api.selectEndOfElement($middle[0])

        it "moves the cursor to the next sibling when moving forward", ->
          atomic.moveCollapsedRange($middle[0], "forward")
          range = new Range($editable[0], window)
          range.insert("a")
          expect(clean($end.html())).toEqual("aend")

        it "moves the cursor to the previous sibling when moving backward", ->
          atomic.moveCollapsedRange($middle[0], "backward")
          range = new Range($editable[0], window)
          range.insert("a")
          expect(clean($start.html())).toEqual("starta")

        it "moves the cursor to the next sibling when clicking", ->
          atomic.moveCollapsedRange($middle[0], "mouse")
          range = new Range($editable[0], window)
          range.insert("a")
          expect(clean($end.html())).toEqual("aend")

      describe "inline", ->
        $span = null
        beforeEach ->
          $editable.html("start<span>middle</span>end")
          $span = $editable.find("span")
          atomic.api.selectEndOfElement($span[0])

        it "moves the cursor to the next sibling when moving forward", ->
          atomic.moveCollapsedRange($span[0], "forward")
          range = new Range($editable[0], window)
          range.insert("a")
          expect(clean($editable.html())).toEqual("start<span>middle</span>aend")

        it "moves the cursor to the previous sibling when moving backward", ->
          atomic.moveCollapsedRange($span[0], "backward")
          range = new Range($editable[0], window)
          range.insert("a")
          expect(clean($editable.html())).toEqual("starta<span>middle</span>end")

        it "moves the cursor to the next sibling when clicking", ->
          atomic.moveCollapsedRange($span[0], "mouse")
          range = new Range($editable[0], window)
          range.insert("a")
          expect(clean($editable.html())).toEqual("start<span>middle</span>aend")

    describe "#moveSelectedRange", ->
      it "moves the start to after the atomic when moving forward", ->
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($middle[0].childNodes[0], 1)
          range.range.setEnd($end[0].childNodes[0], 1)
        else
          range.range.findText("iddle")
          if Browser.isIE7
            # IE7 includes a '\n'.
            range.range.moveEnd("character", 2)
          else
            range.range.moveEnd("character", 1)
        range.select()
        atomic.moveSelectedRange($middle[0], null, "forward")
        range = new Range($editable[0], window)
        range.delete()
        range.insert("a")
        expect(clean($editable.html())).toEqual("<div>start</div><div>middle</div><div>and</div>")

      it "moves the end to after the atomic when moving forward", ->
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($start[0].childNodes[0], 1)
          range.range.setEnd($middle[0].childNodes[0], 1)
        else
          range.range.findText("tart")
          if Browser.isIE7
            # IE7 includes a '\n'.
            range.range.moveEnd("character", 2)
          else
            range.range.moveEnd("character", 1)
        range.select()
        atomic.moveSelectedRange(null, $middle[0], "forward")
        range = new Range($editable[0], window)
        range.delete()
        range.insert("a")
        expect(clean($editable.html())).toEqual("<div>saend</div>")

      it "moves the start to before the atomic when moving backward", ->
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($middle[0].childNodes[0], 1)
          range.range.setEnd($end[0].childNodes[0], 1)
        else
          range.range.findText("iddle")
          if Browser.isIE7
            # IE7 includes a '\n'.
            range.range.moveEnd("character", 2)
          else
            range.range.moveEnd("character", 1)
        range.select()
        atomic.moveSelectedRange($middle[0], null, "backward")
        range = new Range($editable[0], window)
        range.delete()
        range.insert("a")
        expect(clean($editable.html())).toEqual("<div>startand</div>")

      it "moves the end to before the atomic when moving backward", ->
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($start[0].childNodes[0], 1)
          range.range.setEnd($middle[0].childNodes[0], 1)
        else
          range.range.findText("tart")
          if Browser.isIE7
            # IE7 includes a '\n'.
            range.range.moveEnd("character", 2)
          else
            range.range.moveEnd("character", 1)
        range.select()
        atomic.moveSelectedRange(null, $middle[0], "backward")
        range = new Range($editable[0], window)
        range.delete()
        range.insert("a")
        expect(clean($editable.html())).toEqual("<div>sa</div><div>middle</div><div>end</div>")

      it "moves the start to before the atomic when clicking", ->
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($middle[0].childNodes[0], 1)
          range.range.setEnd($end[0].childNodes[0], 1)
        else
          range.range.findText("iddle")
          if Browser.isIE7
            # IE7 includes a '\n'.
            range.range.moveEnd("character", 2)
          else
            range.range.moveEnd("character", 1)
        range.select()
        atomic.moveSelectedRange($middle[0], null, "mouse")
        range = new Range($editable[0], window)
        range.delete()
        range.insert("a")
        expect(clean($editable.html())).toEqual("<div>startand</div>")

      it "moves the end to after the atomic when clicking", ->
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($start[0].childNodes[0], 1)
          range.range.setEnd($middle[0].childNodes[0], 1)
        else
          range.range.findText("tart")
          if Browser.isIE7
            # IE7 includes a '\n'.
            range.range.moveEnd("character", 2)
          else
            range.range.moveEnd("character", 1)
        range.select()
        atomic.moveSelectedRange(null, $middle[0], "mouse")
        range = new Range($editable[0], window)
        range.delete()
        range.insert("a")
        expect(clean($editable.html())).toEqual("<div>saend</div>")


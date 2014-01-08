# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["core/range"], (Range) ->
  describe "Range", ->
    $editable = $start = $end = null
    beforeEach ->
      $editable = addEditableFixture()
      $start = $('<div id="start">start</div>').appendTo($editable)
      $end = $('<div id="end">end</div>').appendTo($editable)

    afterEach ->
      $editable.remove()

    describe "modules", ->
      it "extends browser specific static functions", ->
        expect(-> Range.getBlankRange()).not.toThrow()

      it "includes browser specific instance functions", ->
        range = new Range($editable[0])
        expect(-> range.collapse()).not.toThrow()

      it "includes coordinate functions", ->
        range = new Range($editable[0], $start[0])
        expect(-> range.getCoordinates()).not.toThrow()

    describe "#constructor", ->
      it "throws an error when no el is given", ->
        expect(-> range = new Range()).toThrow()

      it "throws an error when el is not an element", ->
        expect(-> range = new Range($editable)).toThrow()

      it "sets the el with the given el", ->
        range = new Range($editable[0])
        expect(range.el).toBe($editable[0])

      it "sets the document", ->
        range = new Range($editable[0])
        expect(range.doc).toBe(document)

      it "sets the window", ->
        range = new Range($editable[0])
        # NOTE: In IE7/8, Jasmine toBe() craps out when checking window.
        if hasW3CRanges
          expect(range.win).toBe(window)
        else
          expect(range.win).toBeDefined()
          expect(range.win).not.toBeNull()

      it "sets the range to the current selection when the window is given", ->
        spyOn(Range, "getRangeFromSelection").andReturn("range")
        range = new Range($editable[0], window)
        expect(Range.getRangeFromSelection).toHaveBeenCalled()
        expect(range.range).toEqual("range")

      it "sets the range to the given element", ->
        spyOn(Range, "getRangeFromElement").andReturn("range")
        range = new Range($editable[0], $start[0])
        expect(Range.getRangeFromElement).toHaveBeenCalledWith($start[0])
        expect(range.range).toEqual("range")

      it "sets the range to the given range", ->
        givenRange = Range.getBlankRange()
        range = new Range($editable[0], givenRange)
        expect(range.range).toBe(givenRange)

      it "set the range to a blank range when no range is given", ->
        spyOn(Range, "getBlankRange").andReturn("range")
        range = new Range($editable[0])
        expect(Range.getBlankRange).toHaveBeenCalled()
        expect(range.range).toEqual("range")

    describe "#isValid", ->
      it "returns false when there is no range", ->
        if hasW3CRanges
          window.getSelection().removeAllRanges()
        else
          document.selection.empty()
        range = new Range($editable[0], window)
        expect(range.isValid()).toBeFalsy()

      it "returns true when the parent is inside the editable element", ->
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($start[0].childNodes[0], 0)
        else
          range.range.findText("start")
        range.collapse(true)
        expect(range.isValid()).toBeTruthy()

      it "returns true when the parent is the editable element", ->
        $editable.html("editable")
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($editable[0].childNodes[0], 0)
        else
          range.range.findText("editable")
        range.collapse(true)
        expect(range.isValid()).toBeTruthy()

      it "returns false when the parent is not in the editable element", ->
        range = new Range($start[0])
        if hasW3CRanges
          range.range.setStart($end[0].childNodes[0], 0)
        else
          range.range.findText("end")
        range.collapse(true)
        expect(range.isValid()).toBeFalsy()

    describe "#isCollapsed", ->
      it "is defined", ->
        range = new Range($editable[0])
        expect(range.isCollapsed).toBeDefined()

    describe "#getParentElement", ->
      it "returns null if the immediate parent is null", ->
        range = new Range($editable[0])
        spyOn(range, "getImmediateParentElement").andReturn(null)
        expect(range.getParentElement()).toBeNull()
        expect(range.getImmediateParentElement).toHaveBeenCalled()

      it "returns null if the immediate parent is the editable element", ->
        range = new Range($editable[0])
        spyOn(range, "getImmediateParentElement").andReturn($editable[0])
        expect(range.getParentElement()).toBeNull()
        expect(range.getImmediateParentElement).toHaveBeenCalled()

      it "returns null if the immediate parent is the body", ->
        range = new Range($editable[0])
        spyOn(range, "getImmediateParentElement").andReturn(document.body)
        expect(range.getParentElement()).toBeNull()
        expect(range.getImmediateParentElement).toHaveBeenCalled()

      it "returns the immediate parent if no match or null is given", ->
        range = new Range($editable[0])
        spyOn(range, "getImmediateParentElement").andReturn($start[0])
        expect(range.getParentElement()).toBe($start[0])
        expect(range.getParentElement(null)).toBe($start[0])

      it "returns the matched parent if match string is given", ->
        $div = $('<div class="match"><span><i id="i">text</i>more</span>something else</div>').appendTo($editable)
        $span = $div.children("span")
        $i = $("#i")
        range = new Range($editable[0])
        spyOn(range, "getImmediateParentElement").andReturn($i[0])
        expect(range.getParentElement("span")).toBe($span[0])
        expect(range.getParentElement(".match")).toBe($div[0])
        expect(range.getParentElement("td")).toBeNull()

      it "returns the matched parent if match function is given", ->
        $div = $('<div class="match"><span><i id="i">text</i>more</span>something else</div>').appendTo($editable)
        $span = $div.children("span")
        $i = $("#i")
        range = new Range($editable[0])
        spyOn(range, "getImmediateParentElement").andReturn($i[0])
        expect(range.getParentElement((el) -> el.tagName.toLowerCase() == "div")).toBe($div[0])
        expect(range.getParentElement((el) -> el.tagName.toLowerCase() == "td")).toBeNull()

      it "returns null if the match function throws an error", ->
        range = new Range($editable[0])
        spyOn(range, "getImmediateParentElement").andReturn($start[0])
        expect(range.getParentElement((el) -> throw Range.EDITOR_ESCAPE_ERROR)).toBeNull()

      it "returns the image when an image is selected", ->
        $editable.html('<img src="/spec/javascripts/support/assets/images/stub.png" />')
        $img = $editable.find("img")
        range = new Range($editable[0], $img[0])
        range.select()
        el = range.getParentElement()
        expect(el).toBe($img[0])

    describe "#getParentElements", ->
      beforeEach ->
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($start[0].childNodes[0], 4)
          range.range.setEnd($end[0].childNodes[0], 3)
        else
          range.range.findText("star")
          range.collapse(false)
          endRange = new Range($editable[0])
          endRange.range.findText("end")
          range.range.setEndPoint("EndToEnd", endRange.range)
        range.select()

      it "returns the start and end parent elements", ->
        range = new Range($editable[0], window)
        [startElement, endElement] = range.getParentElements()
        expect(startElement).toBe($start[0])
        expect(endElement).toBe($end[0])

      it "returns the image when an image is selected", ->
        $editable.html('<img src="/spec/javascripts/support/assets/images/stub.png" />')
        $img = $editable.find("img")
        range = new Range($editable[0], $img[0])
        range.select()
        range = new Range($editable[0], window)
        [startElement, endElement] = range.getParentElements()
        expect(startElement).toBe($img[0])
        expect(endElement).toBe($img[0])

      it "does not modify the selection", ->
        range = new Range($editable[0], window)
        [startElement, endElement] = range.getParentElements()
        if hasW3CRanges
          $div = $("<div/>").html(range.range.cloneContents())
          $children = $div.children()
          expect($children.length).toEqual(2)
          expect($children[0].innerHTML).toEqual("t")
          expect($children[1].innerHTML).toEqual("end")
        else
          expect(clean(range.range.text)).toEqual("tend")

    describe "#collapse", ->
      it "calls the range's #collapse() with the argument", ->
        range = new Range($editable[0])
        spyOn(range.range, "collapse")
        range.collapse(true)
        expect(range.range.collapse).toHaveBeenCalledWith(true)

      it "returns itself", ->
        range = new Range($editable[0])
        expect(range.collapse(true)).toBe(range)

    describe "#insert", ->
      it "calls #insertHTML() when given a string", ->
        range = new Range($editable[0])
        spyOn(range, "insertHTML")
        range.insert("string")
        expect(range.insertHTML).toHaveBeenCalledWith("string")

      it "calls #insertNode() when given an element", ->
        $el = $("<div/>")
        range = new Range($editable[0])
        spyOn(range, "insertNode")
        range.insert($el[0])
        expect(range.insertNode).toHaveBeenCalledWith($el[0])

      it "inserts over an image", ->
        $editable.html('<img src="/spec/javascripts/support/assets/images/stub.png" />')
        range = new Range($editable[0], $editable.find("img")[0])
        range.select()
        range.insert("<b></b>")
        expect(clean($editable.html())).toEqual("<b></b>")

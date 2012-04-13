describe "Range", ->
  required = ["cs!core/range"]

  $editable = $start = $end = null
  beforeEach ->
    $editable = addEditableFixture()
    $start = $('<div id="start">start</div>').appendTo($editable)
    $end = $('<div id="end">end</div>').appendTo($editable)

  afterEach ->
    $editable.remove()

  describe "modules", ->
    ait "extends browser specific static functions", required, (Range) ->
      expect(-> Range.getBlankRange()).not.toThrow()

    ait "includes browser specific instance functions", required, (Range) ->
      range = new Range($editable[0])
      expect(-> range.collapse()).not.toThrow()

    ait "includes coordinate functions", required, (Range) ->
      range = new Range($editable[0], $start[0])
      expect(-> range.getCoordinates()).not.toThrow()

  describe "#constructor", ->
    ait "sets the el with the given el", required, (Range) ->
      range = new Range($editable[0])
      expect(range.el).toBe($editable[0])

    ait "throws an error when no el is given", required, (Range) ->
      expect(-> range = new Range()).toThrow()

    ait "throws an error when el is not an element", required, (Range) ->
      expect(-> range = new Range($editable)).toThrow()

    ait "sets the range to the current selection when the window is given", required, (Range) ->
      spyOn(Range, "getRangeFromSelection").andReturn("range")
      range = new Range($editable[0], window)
      expect(Range.getRangeFromSelection).toHaveBeenCalled()
      expect(range.range).toEqual("range")

    ait "sets the range to the given element", required, (Range) ->
      spyOn(Range, "getRangeFromElement").andReturn("range")
      range = new Range($editable[0], $start[0])
      expect(Range.getRangeFromElement).toHaveBeenCalledWith($start[0])
      expect(range.range).toEqual("range")

    ait "sets the range to the given range", required, (Range) ->
      givenRange = Range.getBlankRange($editable[0])
      range = new Range($editable[0], givenRange)
      expect(range.range).toBe(givenRange)

    ait "set the range to a blank range when no range is given", required, (Range) ->
      spyOn(Range, "getBlankRange").andReturn("range")
      range = new Range($editable[0])
      expect(Range.getBlankRange).toHaveBeenCalled()
      expect(range.range).toEqual("range")

  describe "#isCollapsed", ->
    ait "is defined", required, (Range) ->
      range = new Range($editable[0])
      expect(range.isCollapsed).toBeDefined()

  describe "#getCoordinates", ->
    ait "TODO", required, (Range) ->
      "TODO"

  describe "#getParentElement", ->
    ait "returns null if the immediate parent is null", required, (Range) ->
      range = new Range($editable[0])
      spyOn(range, "getImmediateParentElement").andReturn(null)
      expect(range.getParentElement()).toBeNull()
      expect(range.getImmediateParentElement).toHaveBeenCalled()

    ait "returns null if the immediate parent is the editable element", required, (Range) ->
      range = new Range($editable[0])
      spyOn(range, "getImmediateParentElement").andReturn($editable[0])
      expect(range.getParentElement()).toBeNull()
      expect(range.getImmediateParentElement).toHaveBeenCalled()

    ait "returns null if the immediate parent is the body", required, (Range) ->
      range = new Range($editable[0])
      spyOn(range, "getImmediateParentElement").andReturn(document.body)
      expect(range.getParentElement()).toBeNull()
      expect(range.getImmediateParentElement).toHaveBeenCalled()

    ait "returns the immediate parent if no match or null is given", required, (Range) ->
      range = new Range($editable[0])
      spyOn(range, "getImmediateParentElement").andReturn($start[0])
      expect(range.getParentElement()).toBe($start[0])
      expect(range.getParentElement(null)).toBe($start[0])

    ait "returns the matched parent if match string is given", required, (Range) ->
      $div = $('<div class="match"><span><i id="i">text</i>more</span>something else</div>').appendTo($editable)
      $span = $div.children("span")
      $i = $("#i")
      range = new Range($editable[0])
      spyOn(range, "getImmediateParentElement").andReturn($i[0])
      expect(range.getParentElement("span")).toBe($span[0])
      expect(range.getParentElement(".match")).toBe($div[0])
      expect(range.getParentElement("td")).toBeNull()

    ait "returns the matched parent if match function is given", required, (Range) ->
      $div = $('<div class="match"><span><i id="i">text</i>more</span>something else</div>').appendTo($editable)
      $span = $div.children("span")
      $i = $("#i")
      range = new Range($editable[0])
      spyOn(range, "getImmediateParentElement").andReturn($i[0])
      expect(range.getParentElement((el) -> el.tagName.toLowerCase() == "div")).toBe($div[0])
      expect(range.getParentElement((el) -> el.tagName.toLowerCase() == "td")).toBeNull()

    ait "returns null if the match function throws an error", required, (Range) ->
      range = new Range($editable[0])
      spyOn(range, "getImmediateParentElement").andReturn($start[0])
      expect(range.getParentElement((el) -> throw Range.EDITOR_ESCAPE_ERROR)).toBeNull()

  describe "#collapse", ->
    ait "calls the range's #collapse() with the argument", required, (Range) ->
      range = new Range($editable[0])
      spyOn(range.range, "collapse")
      range.collapse(true)
      expect(range.range.collapse).toHaveBeenCalledWith(true)

    ait "returns itself", required, (Range) ->
      range = new Range($editable[0])
      expect(range.collapse(true)).toBe(range)

  describe "#paste", ->
    ait "calls #pasteHTML() when given a string", required, (Range) ->
      range = new Range($editable[0])
      spyOn(range, "pasteHTML")
      range.paste("string")
      expect(range.pasteHTML).toHaveBeenCalledWith("string")

    ait "calls #pasteNode() when given an element", required, (Range) ->
      $el = $("<div/>")
      range = new Range($editable[0])
      spyOn(range, "pasteNode")
      range.paste($el[0])
      expect(range.pasteNode).toHaveBeenCalledWith($el[0])

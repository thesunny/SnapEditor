if isWebkit
  describe "EraseHandler", ->
    required = ["plugins/erase_handler/erase_handler", "core/range"]

    $editable = $h1 = $p = API = null
    beforeEach ->
      $editable = addEditableFixture()
      $h1 = $("<h1>header heading</h1>").appendTo($editable)
      $p = $("<p>some text</p>").appendTo($editable)
      class API
        constructor: (@Range) ->
        range: (el) -> new @Range($editable[0], el or window)
        remove: -> @range().remove()

    afterEach ->
      $editable.remove()

    describe "#handleCursor", ->
      ait "merges the nodes together when deleting", required, (Handler, Range) ->
        range = new Range($editable[0])
        range.range.selectNodeContents($h1[0])
        range.collapse(false)
        range.select()

        handler = new Handler()
        handler.api = new API(Range)
        handler.handleCursor(which: 46, type: "keydown", preventDefault: ->)
        expect($editable.html()).toEqual("<h1>header headingsome text</h1>")

        range = new Range($editable[0], window)
        range.paste("<b></b>")
        expect($h1.html()).toEqual("header heading<b></b>some text")

      ait "merges the nodes together when backspacing", required, (Handler, Range) ->
        range = new Range($editable[0])
        range.range.selectNodeContents($p[0])
        range.collapse(true)
        range.select()

        handler = new Handler()
        handler.api = new API(Range)
        handler.handleCursor(which: 8, type: "keydown", preventDefault: ->)
        expect($editable.html()).toEqual("<h1>header headingsome text</h1>")

        range = new Range($editable[0], window)
        range.paste("<b></b>")
        expect($h1.html()).toEqual("header heading<b></b>some text")

    describe "#handleSelection", ->
      ait "does nothing when the selection is within the same element", required, (Handler, Range) ->
        range = new Range($editable[0])
        range.range.setStart($h1[0].childNodes[0], 0)
        range.range.setEnd($h1[0].childNodes[0], 6)
        range.select()

        handler = new Handler()
        handler.api = new API(Range)
        spyOn(handler, "mergeNodes")
        handler.handleSelection(preventDefault: ->)
        expect(handler.mergeNodes).not.toHaveBeenCalled()

      ait "deletes the content and merges the nodes together when the selection crosses elements", required, (Handler, Range) ->
        range = new Range($editable[0])
        range.range.setStart($h1[0].childNodes[0], 6)
        range.range.setEnd($p[0].childNodes[0], 4)
        range.select()

        handler = new Handler()
        handler.api = new API(Range)
        handler.handleSelection(preventDefault: ->)
        expect($editable.html()).toEqual("<h1>header text</h1>")

        range = new Range($editable[0], window)
        range.paste("<b></b>")
        expect($h1.html()).toEqual("header<b></b> text")

    describe "#isBlockElement", ->
      ait "returns true given a block element", required, (Handler, Range) ->
        handler = new Handler()
        expect(handler.isBlockElement($("<div/>").appendTo($editable))).toBeTruthy()

      ait "returns true given an inline element displayed as a block", required, (Handler, Range) ->
        handler = new Handler()
        expect(handler.isBlockElement($('<span style="display: block;"></span>').appendTo($editable))).toBeTruthy()

      ait "returns true given an li", required, (Handler, Range) ->
        handler = new Handler()
        expect(handler.isBlockElement($("<li/>").appendTo($editable))).toBeTruthy()

      ait "return false otherwise", required, (Handler, Range) ->
        handler = new Handler()
        expect(handler.isBlockElement($("<span/>").appendTo($editable))).toBeFalsy()

    describe "#mergeNodes", ->
      ait "merges the nodes together", required, (Handler, Range) ->
        handler = new Handler()
        handler.api = new API(Range)
        handler.mergeNodes($h1[0], $p[0])
        expect($editable.html()).toEqual("<h1>header headingsome text</h1>")

      ait "places the selection at the front", required, (Handler, Range) ->
        handler = new Handler()
        handler.api = new API(Range)
        handler.mergeNodes($h1[0], $p[0])

        range = new Range($editable[0], window)
        range.paste("<b></b>")
        expect($h1.html()).toEqual("header heading<b></b>some text")

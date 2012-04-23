# This test uses the Range object directly instead of the module because the
# module depends quite heavily on the Range object. However, the tests should
# still be only testing the functionality of the module.
if isIE8
  describe "Range.Coordinates.IE8", ->
    required = ["core/range"]

    $editable = $div = $first = $second = null
    beforeEach ->
      $editable = addEditableFixture()
      $div = $('<div id="top" style="font-size:12px;padding:100px 0 0 200px"></div>').appendTo($editable)
      $first = $('<p>first</p>').appendTo($div)
      $second = $('<p>second</p>').appendTo($div)
      # IE8 requires the focus to be on $editable in order
      # for ranges to work properly.
      $editable.focus()

    afterEach ->
      $editable.remove()

    describe "#getEdgeCoordinates", ->
      describe "collapsed", ->
        ait "returns the coordinates of the start of the range", required, (Range) ->
          range = new Range($editable[0], $first[0])
          range.collapse(true)
          coords = range.getEdgeCoordinates(true)
          expect(coords.top).toEqual(100)
          expect(coords.bottom).toEqual(114)
          expect(coords.left).toEqual(200)
          expect(coords.right).toEqual(200)
          expect(coords.width).toEqual(0)
          expect(coords.height).toEqual(14)

        ait "returns the coordinates of the end of the range", required, (Range) ->
          range = new Range($editable[0], $first[0])
          range.collapse(true)
          coords = range.getEdgeCoordinates(false)
          expect(coords.top).toEqual(100)
          expect(coords.bottom).toEqual(114)
          expect(coords.left).toEqual(200)
          expect(coords.right).toEqual(200)
          expect(coords.width).toEqual(0)
          expect(coords.height).toEqual(14)

        ait "does not alter the HTML", required, (Range) ->
          html = $editable.html()
          range = new Range($editable[0], $first[0])
          range.collapse(true)
          coords = range.getEdgeCoordinates(true)
          expect($editable.html()).toEqual(html)

        ait "does not alter the range", required, (Range) ->
          range = new Range($editable[0], $first[0])
          range.collapse(true)
          expectedRange = range.range
          coords = range.getEdgeCoordinates(true)
          expect(range.range.isEqual(expectedRange)).toBeTruthy()

      describe "not collapsed", ->
        ait "returns the coordinates of the start of the range", required, (Range) ->
          firstRange = Range.getRangeFromElement($first[0])
          secondRange = Range.getRangeFromElement($second[0])
          range = new Range($editable[0])
          range.range.setEndPoint("StartToStart", firstRange)
          range.range.setEndPoint("EndToStart", secondRange)
          coords = range.getEdgeCoordinates(true)
          expect(coords.top).toEqual(100)
          expect(coords.bottom).toEqual(114)
          expect(coords.left).toEqual(200)
          expect(coords.right).toEqual(200)
          expect(coords.width).toEqual(0)
          expect(coords.height).toEqual(14)

        ait "returns the coordinates of the end of the range", required, (Range) ->
          firstRange = Range.getRangeFromElement($first[0])
          secondRange = Range.getRangeFromElement($second[0])
          range = new Range($editable[0])
          range.range.setEndPoint("StartToStart", firstRange)
          range.range.setEndPoint("EndToStart", secondRange)
          coords = range.getEdgeCoordinates(false)
          expect(coords.top).toEqual(114)
          expect(coords.bottom).toEqual(128)
          expect(coords.left).toEqual(200)
          expect(coords.right).toEqual(200)
          expect(coords.width).toEqual(0)
          expect(coords.height).toEqual(14)

        ait "does not alter the HTML", required, (Range) ->
          html = $editable.html()
          firstRange = Range.getRangeFromElement($first[0])
          secondRange = Range.getRangeFromElement($second[0])
          range = new Range($editable[0])
          range.range.setEndPoint("StartToStart", firstRange)
          range.range.setEndPoint("EndToStart", secondRange)
          coords = range.getEdgeCoordinates(true)
          expect($editable.html()).toEqual(html)

        ait "does not alter the range", required, (Range) ->
          firstRange = Range.getRangeFromElement($first[0])
          secondRange = Range.getRangeFromElement($second[0])
          range = new Range($editable[0])
          range.range.setEndPoint("StartToStart", firstRange)
          range.range.setEndPoint("EndToStart", secondRange)
          expectedRange = range.range
          coords = range.getEdgeCoordinates(true)
          expect(range.range.isEqual(expectedRange)).toBeTruthy()

    describe "#getCoordinates", ->
      describe "text", ->
        ait "calls #getEdgeCoordinates for the start when collapsed", required, (Range) ->
          range = new Range($editable[0], $first[0])
          spyOn(range, "getEdgeCoordinates").andReturn("coords")
          range.collapse(true)
          expect(range.getCoordinates()).toEqual("coords")
          expect(range.getEdgeCoordinates).toHaveBeenCalledWith(true)

        ait "calls #getEdgeCoordinates for the start and end when not collapsed", required, (Range) ->
          range = new Range($editable[0], $first[0])
          spyOn(range, "getEdgeCoordinates").andCallFake((start) -> if start then top: 50 else bottom: 10)
          coords = range.getCoordinates()
          expect(coords.top).toEqual(50)
          expect(coords.bottom).toEqual(10)
          expect(range.getEdgeCoordinates.callCount).toEqual(2)
          expect(range.getEdgeCoordinates.argsForCall[0][0]).toBeTruthy()
          expect(range.getEdgeCoordinates.argsForCall[1][0]).toBeFalsy()

      describe "image", ->
        $img = null
        beforeEach ->
          $img = $('<img style="width:100px;height:200px"/>').prependTo($div)

        ait "returns the coordinates of the image", required, (Range) ->
          range = new Range($editable[0], $img[0])
          coords = range.getCoordinates()
          expect(coords.top).toEqual(100)
          expect(coords.bottom).toEqual(300)
          expect(coords.left).toEqual(200)
          expect(coords.right).toEqual(300)
          expect(coords.width).toEqual(100)
          expect(coords.height).toEqual(200)

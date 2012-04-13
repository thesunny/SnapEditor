# This test uses the Range object directly instead of the module because the
# module depends quite heavily on the Range object. However, the tests should
# still be only testing the functionality of the module.
if isIE7
  describe "Range.Coordinates.IE7", ->
    required = ["cs!core/range"]

    $editable = $div = $first = $second = null
    beforeEach ->
      $editable = addEditableFixture()
      $div = $('<div id="top" style="font-size:12px;padding:100px 0 0 200px"></div>').appendTo($editable)
      $first = $('<p>first</p>').appendTo($div)
      $second = $('<p>second</p>').appendTo($div)

    afterEach ->
      $editable.remove()

    describe "#getCoordinates", ->
      describe "text", ->
        describe "collapsed", ->
          ait "returns the coordinates the range", required, (Range) ->
            range = new Range($editable[0], $first[0])
            range.collapse(true)
            coords = range.getCoordinates()
            # NOTE: Even though there is only supposed to be 100px padding on
            # top, the top of the text is 116px from the top of the page. This
            # has been verified by taking a screenshot and measuring. The same
            # happens with the left coordinates.
            expect(coords.top).toEqual(116)
            expect(coords.bottom).toEqual(130)
            expect(coords.left).toEqual(202)
            expect(coords.right).toEqual(202)

          ait "does not alter the HTML", required, (Range) ->
            html = $editable.html()
            range = new Range($editable[0], $first[0])
            range.collapse(true)
            coords = range.getCoordinates()
            expect($editable.html()).toEqual(html)

          ait "does not alter the range", required, (Range) ->
            range = new Range($editable[0], $first[0])
            range.collapse(true)
            expectedRange = range.range
            coords = range.getCoordinates()
            expect(range.range.isEqual(expectedRange)).toBeTruthy()

        describe "not collapsed", ->
          ait "returns the coordinates of the range", required, (Range) ->
            firstRange = Range.getRangeFromElement($first[0])
            secondRange = Range.getRangeFromElement($second[0])
            range = new Range($editable[0])
            range.range.setEndPoint("StartToStart", firstRange)
            range.range.setEndPoint("EndToEnd", secondRange)
            coords = range.getCoordinates()
            # NOTE: Even though there is only supposed to be 100px padding on
            # top, the top of the text is 116px from the top of the page. This
            # has been verified by taking a screenshot and measuring. The same
            # happens with the left coordinates.
            expect(coords.top).toEqual(116)
            expect(coords.bottom).toEqual(144)
            expect(coords.left).toEqual(202)
            expect(coords.right).toEqual(244)

          ait "does not alter the HTML", required, (Range) ->
            html = $editable.html()
            firstRange = Range.getRangeFromElement($first[0])
            secondRange = Range.getRangeFromElement($second[0])
            range = new Range($editable[0])
            range.range.setEndPoint("StartToStart", firstRange)
            range.range.setEndPoint("EndToEnd", secondRange)
            coords = range.getCoordinates()
            expect($editable.html()).toEqual(html)

          ait "does not alter the range", required, (Range) ->
            firstRange = Range.getRangeFromElement($first[0])
            secondRange = Range.getRangeFromElement($second[0])
            range = new Range($editable[0])
            range.range.setEndPoint("StartToStart", firstRange)
            range.range.setEndPoint("EndToEnd", secondRange)
            expectedRange = range.range
            coords = range.getCoordinates()
            expect(range.range.isEqual(expectedRange)).toBeTruthy()

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

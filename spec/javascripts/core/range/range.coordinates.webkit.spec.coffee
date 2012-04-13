# This test uses the Range object directly instead of the module because the
# module depends quite heavily on the Range object. However, the tests should
# still be only testing the functionality of the module.
if isWebkit
  describe "Range.Coordinates.Webkit", ->
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
          ait "returns the coordinates of the range", required, (Range) ->
            range = new Range($editable[0])
            range.range.selectNodeContents($first[0])
            range.collapse(true)
            coords = range.getCoordinates()
            expect(coords.top).toEqual(100)
            # The bottom fluctuates depending on the font. From what I've seen,
            # when running with the headless webkit, I get 115. When running in
            # Chrome, I get 114.
            expect(coords.bottom).toBeGreaterThan(113)
            expect(coords.bottom).toBeLessThan(116)
            expect(coords.left).toEqual(200)
            expect(coords.right).toEqual(200)

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
            expect(range.range.compareBoundaryPoints(Range.START_TO_START, expectedRange)).toEqual(0)
            expect(range.range.compareBoundaryPoints(Range.END_TO_END, expectedRange)).toEqual(0)

        describe "not collapsed", ->
          ait "returns the coordinates of the range", required, (Range) ->
            range = new Range($editable[0], $first[0])
            range.range.setEnd($second[0], 1)
            range.select()
            coords = range.getCoordinates()
            expect(coords.top).toEqual(100)
            # The bottom fluctuates depending on the font. From what I've seen,
            # when running with the headless webkit, I get 130. When running in
            # Chrome, I get 128.
            expect(coords.bottom).toBeGreaterThan(127)
            expect(coords.bottom).toBeLessThan(131)
            expect(coords.left).toEqual(200)
            # When the selection spans multiple lines, the right side is the
            # width of the window.
            expect(coords.right).toEqual($(window).width())

          ait "does not alter the HTML", required, (Range) ->
            html = $editable.html()
            range = new Range($editable[0], $first[0])
            range.range.setEnd($second[0], 1)
            coords = range.getCoordinates()
            expect($editable.html()).toEqual(html)

          ait "does not alter the range", required, (Range) ->
            range = new Range($editable[0], $first[0])
            range.range.setEnd($second[0], 1)
            expectedRange = range.range
            coords = range.getCoordinates()
            expect(range.range.compareBoundaryPoints(Range.START_TO_START, expectedRange)).toEqual(0)
            expect(range.range.compareBoundaryPoints(Range.END_TO_END, expectedRange)).toEqual(0)

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

# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# This test uses the Range object directly instead of the module because the
# module depends quite heavily on the Range object. However, the tests should
# still be only testing the functionality of the module.
if isGecko1
  describe "Range.Coordinates.Gecko1", ->
    required = ["core/range"]

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
            expect(coords.bottom).toEqual(114)

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
            expect(coords.top).toEqual(114)
            expect(coords.bottom).toEqual(128)

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
          # NOTE: In Gecko1, the img must have a src and it must be loadable in
          # order for the image to be displayed. Simply setting the style will
          # not display a broken image with the specified width and height.
          $img = $('<img src="spec/javascripts/support/assets/images/stub.png" style="width:100px;height:200px"/>').prependTo($div)

        ait "returns the coordinates of the image", required, (Range) ->
          range = new Range($editable[0], $img[0])
          coords = range.getCoordinates()
          expect(coords.top).toEqual(289)
          expect(coords.bottom).toEqual(303)

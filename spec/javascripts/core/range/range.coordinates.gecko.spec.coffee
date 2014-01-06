# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# This test uses the Range object directly instead of the module because the
# module depends quite heavily on the Range object. However, the tests should
# still be only testing the functionality of the module.
require ["core/range"], (Range) ->
  if isGecko and not isGecko1
    describe "Range.Coordinates.Gecko", ->
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
            it "returns the coordinates of the range", ->
              range = new Range($editable[0])
              range.range.selectNodeContents($first[0])
              range.collapse(true)
              coords = range.getCoordinates()
              expect(coords.top).toEqual(100)
              expect(coords.bottom).toEqual(115)
              expect(coords.left).toEqual(200)
              expect(coords.right).toEqual(200)

            it "does not alter the HTML", ->
              html = $editable.html()
              range = new Range($editable[0], $first[0])
              range.collapse(true)
              coords = range.getCoordinates()
              expect($editable.html()).toEqual(html)

            it "does not alter the range", ->
              range = new Range($editable[0], $first[0])
              range.collapse(true)
              expectedRange = range.range
              coords = range.getCoordinates()
              expect(range.range.compareBoundaryPoints(Range.START_TO_START, expectedRange)).toEqual(0)
              expect(range.range.compareBoundaryPoints(Range.END_TO_END, expectedRange)).toEqual(0)

          describe "not collapsed", ->
            it "returns the coordinates of the range", ->
              range = new Range($editable[0], $first[0])
              range.range.setEnd($second[0], 1)
              range.select()
              coords = range.getCoordinates()
              expect(coords.top).toEqual(100)
              expect(coords.bottom).toEqual(130)
              expect(coords.left).toEqual(200)
              # When the selection spans multiple lines, the right side is the
              # width of the window.
              expect(coords.right).toEqual($(window).width())

            it "does not alter the HTML", ->
              html = $editable.html()
              range = new Range($editable[0], $first[0])
              range.range.setEnd($second[0], 1)
              coords = range.getCoordinates()
              expect($editable.html()).toEqual(html)

            it "does not alter the range", ->
              range = new Range($editable[0], $first[0])
              range.range.setEnd($second[0], 1)
              expectedRange = range.range
              coords = range.getCoordinates()
              expect(range.range.compareBoundaryPoints(Range.START_TO_START, expectedRange)).toEqual(0)
              expect(range.range.compareBoundaryPoints(Range.END_TO_END, expectedRange)).toEqual(0)

        describe "image", ->
          $img = null
          beforeEach ->
            # NOTE: In Gecko, the img must have a src and it must be loadable in
            # order for the image to be displayed. Simply setting the style will
            # not display a broken image with the specified width and height.
            $img = $('<img src="spec/javascripts/support/assets/images/stub.png" style="width:100px;height:200px"/>').prependTo($div)

          it "returns the coordinates of the image", ->
            range = new Range($editable[0], $img[0])
            coords = range.getCoordinates()
            expect(coords.top).toEqual(100)
            expect(coords.bottom).toEqual(300)
            expect(coords.left).toEqual(200)
            expect(coords.right).toEqual(300)

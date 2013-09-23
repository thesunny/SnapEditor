# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# This test uses the Range object directly instead of the module because the
# module depends quite heavily on the Range object. However, the tests should
# still be only testing the functionality of the module.
if isIE10
  require ["core/range"], (Range) ->
    describe "Range.Coordinates.IE10", ->
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
              expect(coords.bottom).toEqual(114)
              expect(coords.left).toEqual(200)
              expect(coords.right).toEqual(200)

            it "returns the coordinates of the range when it's at the end of the document", ->
              range = new Range($editable[0])
              range.range.setStart($second[0].childNodes[0], 5)
              range.collapse(true)
              coords = range.getCoordinates()
              expect(coords.top).toEqual(114)
              expect(coords.bottom).toEqual(128)
              expect(coords.left).toEqual(227)
              expect(coords.right).toEqual(227)

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
              coords = range.getCoordinates()
              expect(coords.top).toEqual(100)
              expect(coords.bottom).toEqual(128)
              expect(coords.left).toEqual(200)
              expect(coords.right).toEqual(233)

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
            $img = $('<img style="width:100px;height:200px"/>').prependTo($div)

          it "returns the coordinates of the image", ->
            range = new Range($editable[0], $img[0])
            coords = range.getCoordinates()
            expect(coords.top).toEqual(100)
            expect(coords.bottom).toEqual(300)
            expect(coords.left).toEqual(200)
            expect(coords.right).toEqual(300)
            expect(coords.width).toEqual(100)
            expect(coords.height).toEqual(200)

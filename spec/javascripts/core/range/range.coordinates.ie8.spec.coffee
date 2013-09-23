# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# This test uses the Range object directly instead of the module because the
# module depends quite heavily on the Range object. However, the tests should
# still be only testing the functionality of the module.
if isIE8
  require ["jquery.custom", "core/range"], ($, Range) ->
    describe "Range.Coordinates.IE8", ->
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
          it "returns the coordinates of the start of the range", ->
            range = new Range($editable[0], $first[0])
            range.collapse(true)
            coords = range.getEdgeCoordinates(true)
            expect(coords.top).toEqual(100)
            expect(coords.bottom).toEqual(115)
            expect(coords.left).toEqual(200)
            expect(coords.right).toEqual(200)
            expect(coords.width).toEqual(0)
            expect(coords.height).toEqual(15)

          it "returns the coordinates of the end of the range", ->
            range = new Range($editable[0], $first[0])
            range.collapse(true)
            coords = range.getEdgeCoordinates(false)
            expect(coords.top).toEqual(100)
            expect(coords.bottom).toEqual(115)
            expect(coords.left).toEqual(200)
            expect(coords.right).toEqual(200)
            expect(coords.width).toEqual(0)
            expect(coords.height).toEqual(15)

          it "does not alter the HTML", ->
            html = $editable.html()
            range = new Range($editable[0], $first[0])
            range.collapse(true)
            coords = range.getEdgeCoordinates(true)
            expect($editable.html()).toEqual(html)

          it "does not alter the range", ->
            range = new Range($editable[0], $first[0])
            range.collapse(true)
            expectedRange = range.range
            coords = range.getEdgeCoordinates(true)
            expect(range.range.isEqual(expectedRange)).toBeTruthy()

        describe "not collapsed", ->
          it "returns the coordinates of the start of the range", ->
            firstRange = Range.getRangeFromElement($first[0])
            secondRange = Range.getRangeFromElement($second[0])
            range = new Range($editable[0])
            range.range.setEndPoint("StartToStart", firstRange)
            range.range.setEndPoint("EndToStart", secondRange)
            coords = range.getEdgeCoordinates(true)
            expect(coords.top).toEqual(100)
            expect(coords.bottom).toEqual(115)
            expect(coords.left).toEqual(200)
            expect(coords.right).toEqual(200)
            expect(coords.width).toEqual(0)
            expect(coords.height).toEqual(15)

          it "returns the coordinates of the end of the range", ->
            firstRange = Range.getRangeFromElement($first[0])
            secondRange = Range.getRangeFromElement($second[0])
            range = new Range($editable[0])
            range.range.setEndPoint("StartToStart", firstRange)
            range.range.setEndPoint("EndToStart", secondRange)
            coords = range.getEdgeCoordinates(false)
            expect(coords.top).toEqual(115)
            expect(coords.bottom).toEqual(130)
            expect(coords.left).toEqual(200)
            expect(coords.right).toEqual(200)
            expect(coords.width).toEqual(0)
            expect(coords.height).toEqual(15)

          it "does not alter the HTML", ->
            html = $editable.html()
            firstRange = Range.getRangeFromElement($first[0])
            secondRange = Range.getRangeFromElement($second[0])
            range = new Range($editable[0])
            range.range.setEndPoint("StartToStart", firstRange)
            range.range.setEndPoint("EndToStart", secondRange)
            coords = range.getEdgeCoordinates(true)
            expect($editable.html()).toEqual(html)

          it "does not alter the range", ->
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
          it "returns the bounding rectangle when collapsed", ->
            spyOn($.fn, "getScroll").andReturn(x: 10, y: 100)
            range = new Range($editable[0], $first[0])
            range.collapse(true)
            coords = range.getCoordinates()
            expect(coords.top).toEqual(200)
            expect(coords.bottom).toEqual(215)
            expect(coords.left).toEqual(210)
            expect(coords.right).toEqual(210)

          it "returns the bounding rectangle when not collapsed", ->
            spyOn($.fn, "getScroll").andReturn(x: 10, y: 100)
            range = new Range($editable[0], $first[0])
            coords = range.getCoordinates()
            expect(coords.top).toEqual(200)
            expect(coords.bottom).toEqual(215)
            expect(coords.left).toEqual(210)
            expect(coords.right).toEqual(230)

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

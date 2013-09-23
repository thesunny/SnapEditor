# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# This test uses the Range object directly instead of the module because the
# module depends quite heavily on the Range object. However, the tests should
# still be only testing the functionality of the module.
if isIE7
  require ["jquery.custom", "core/range"], ($, Range) ->
    describe "Range.Coordinates.IE7", ->
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
              range = new Range($editable[0], $first[0])
              range.collapse(true)
              coords = range.getCoordinates()
              # NOTE: Even though there is only supposed to be 100px padding on
              # top, the top of the text is 117px from the top of the page. This
              # has been verified by taking a screenshot and measuring. The same
              # happens with the left coordinates.
              expect(coords.top).toEqual(117)
              expect(coords.bottom).toEqual(132)
              expect(coords.left).toEqual(202)
              expect(coords.right).toEqual(202)

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
              expect(range.range.isEqual(expectedRange)).toBeTruthy()

          describe "not collapsed", ->
            it "returns the coordinates of the range", ->
              firstRange = Range.getRangeFromElement($first[0])
              secondRange = Range.getRangeFromElement($second[0])
              range = new Range($editable[0])
              range.range.setEndPoint("StartToStart", firstRange)
              range.range.setEndPoint("EndToEnd", secondRange)
              coords = range.getCoordinates()
              # NOTE: Even though there is only supposed to be 100px padding on
              # top, the top of the text is 117px from the top of the page. This
              # has been verified by taking a screenshot and measuring. The same
              # happens with the left coordinates.
              expect(coords.top).toEqual(117)
              expect(coords.bottom).toEqual(147)
              expect(coords.left).toEqual(202)
              expect(coords.right).toEqual(238)

            it "does not alter the HTML", ->
              html = $editable.html()
              firstRange = Range.getRangeFromElement($first[0])
              secondRange = Range.getRangeFromElement($second[0])
              range = new Range($editable[0])
              range.range.setEndPoint("StartToStart", firstRange)
              range.range.setEndPoint("EndToEnd", secondRange)
              coords = range.getCoordinates()
              expect($editable.html()).toEqual(html)

            it "does not alter the range", ->
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

          it "returns the coordinates of the image", ->
            range = new Range($editable[0], $img[0])
            coords = range.getCoordinates()
            expect(coords.top).toEqual(100)
            expect(coords.bottom).toEqual(300)
            expect(coords.left).toEqual(200)
            expect(coords.right).toEqual(300)
            expect(coords.width).toEqual(100)
            expect(coords.height).toEqual(200)

require ["jquery.custom", "core/api", "core/range"], ($, API, Range) ->
  describe "API", ->
    api = $editable = $table = $td = null
    beforeEach ->
      $editable = addEditableFixture()
      $table = $('<table><tbody><tr><td id="td">cell</td><td>another</td></tr></tbody></table>').appendTo($editable)
      $td = $("#td")
      api = new API(
        $el: $editable
        config: path: "/"
        contents: null
        activate: null
        assets: {}
        whitelist: {}
      )

    afterEach ->
      $editable.remove()

    describe "#constructor", ->
      it "saves the editor", ->
        expect(api.editor).toBeDefined()
        expect(api.editor).not.toBeNull()

      it "saves the el", ->
        expect(api.el).toEqual($editable[0])

    describe "#getRange", ->
      it "returns the selection when no element is given", ->
        expectedRange = new Range($editable[0], $td[0])
        expectedRange.selectEndOfElement($td[0])

        range = api.getRange()
        range.insert("test")
        expect($td.html()).toEqual("celltest")

      it "returns the element's range when an element is given", ->
        range = api.getRange($td[0])
        expect(range.getParentElement("tr")).not.toBeNull()

    describe "#getCoordinatesRelativeToOuter", ->
      mouseCoords = x: 100, y: 200
      elCoords =
        top: 100
        bottom: 200
        left: 300
        right: 400

      describe "mouseCoords", ->
        it "returns the same coordinates when there is no iframe", ->
          expect(api.getCoordinatesRelativeToOuter(mouseCoords)).toBe(mouseCoords)

        it "returns the translated coordinates when there is an iframe", ->
          api.editor = iframe: "iframe"
          spyOn(api, "doc").andReturn("doc")
          spyOn($.fn, "getScroll").andReturn(x: 5, y: 10)
          spyOn($.fn, "getCoordinates").andReturn(
            top: 1
            bottom: 2
            left: 3
            right: 4
          )
          outerCoords = api.getCoordinatesRelativeToOuter(mouseCoords)
          expect(outerCoords.x).toEqual(98)
          expect(outerCoords.y).toEqual(191)

      describe "elCoords", ->
        it "returns the same coordinates when there is no iframe", ->
          expect(api.getCoordinatesRelativeToOuter(elCoords)).toBe(elCoords)

        it "returns the translated coordinates when there is an iframe", ->
          api.editor = iframe: "iframe"
          spyOn(api, "doc").andReturn("doc")
          spyOn($.fn, "getScroll").andReturn(x: 5, y: 10)
          spyOn($.fn, "getCoordinates").andReturn(
            top: 1
            bottom: 2
            left: 3
            right: 4
          )
          outerCoords = api.getCoordinatesRelativeToOuter(elCoords)
          expect(outerCoords.top).toEqual(91)
          expect(outerCoords.bottom).toEqual(191)
          expect(outerCoords.left).toEqual(298)
          expect(outerCoords.right).toEqual(398)

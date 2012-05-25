require ["core/api", "core/range"], (API, Range) ->
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

    describe "#range", ->
      it "returns the selection when no element is given", ->
        expectedRange = new Range($editable[0], $td[0])
        expectedRange.selectEndOfElement($td[0])

        range = api.range()
        range.paste("test")
        expect($td.html()).toEqual("celltest")

      it "returns the element's range when an element is given", ->
        range = api.range($td[0])
        expect(range.getParentElement("tr")).not.toBeNull()

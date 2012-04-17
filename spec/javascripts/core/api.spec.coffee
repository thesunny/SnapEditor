describe "API", ->
  required = ["cs!core/api", "cs!core/range"]

  editor = $editable = $table = $td = null
  beforeEach ->
    $editable = addEditableFixture()
    $table = $('<table><tbody><tr><td id="td">cell</td><td>another</td></tr></tbody></table>').appendTo($editable)
    $td = $("#td")
    editor =
      $el: $editable
      contents: null
      activate: null

  afterEach ->
    $editable.remove()

  describe "#constructor", ->
    ait "saves the editor", required, (API, Range) ->
      api = new API(editor)
      expect(api.editor).toEqual(editor)

    ait "saves the el", required, (API, Range) ->
      api = new API(editor)
      expect(api.el).toEqual(editor.$el[0])

  describe "#contents", -> # TODO: Write tests.

  describe "#activate", -> # TODO: Write tests.

  describe "#range", ->
    ait "returns the selection when no element is given", required, (API, Range) ->
      expectedRange = new Range($editable[0], $td[0])
      expectedRange.selectEndOfTableCell($td[0])

      api = new API(editor)
      range = api.range()
      range.paste("test")
      expect($td.html()).toEqual("celltest")

    ait "returns the element's range when an element is given", required, (API, Range) ->
      api = new API(editor)
      range = api.range($td[0])
      expect(range.getParentElement("tr")).not.toBeNull()

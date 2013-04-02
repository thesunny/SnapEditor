require ["jquery.custom", "plugins/empty_handler/empty_handler", "core/helpers", "core/range"], ($, Handler, Helpers, Range) ->
  describe "EmptyHandler", ->
    $editable = handler = api = null
    beforeEach ->
      $editable = addEditableFixture()
      $editable.html("<h1>Heading 1</h1><p>with some text</p>")
      handler = window.SnapEditor.internalPlugins.emptyHandler
      api =
        el: $editable[0]
        getDefaultBlock: -> $("<p/>")
        getBlankRange: -> new Range($editable[0])
        isValid: -> true
      Helpers.delegate(api, "getBlankRange()", "selectEndOfElement")

    afterEach ->
      $editable.remove()

    describe "#deleteAll", ->
      it "removes all content and replaces it with the default block", ->
        handler.deleteAll(api)
        expect(clean($editable.html())).toEqual("<p></p>")

      it "puts the selection at the end of the default block", ->
        handler.deleteAll(api)
        range = new Range($editable[0], window)
        range.insert("<b></b>")
        expect(clean($editable.html())).toEqual("<p><b></b></p>")

require ["jquery.custom", "plugins/empty_handler/empty_handler", "core/helpers", "core/range"], ($, Handler, Helpers, Range) ->
  describe "EmptyHandler", ->
    $editable = handler = null
    beforeEach ->
      $editable = addEditableFixture()
      $editable.html("<h1>Heading 1</h1><p>with some text</p>")
      handler = new Handler()
      handler.api = 
        el: $editable[0]
        defaultBlock: -> $("<p/>")
        blankRange: -> new Range($editable[0])
        isValid: -> true
      Helpers.delegate(handler.api, "blankRange()", "selectEndOfElement")

    afterEach ->
      $editable.remove()

    describe "#deleteAll", ->
      beforeEach ->
        handler.api.defaultBlock = -> $("<p/>")

      it "removes all content and replaces it with the default block", ->
        handler.deleteAll()
        expect(clean($editable.html())).toEqual("<p></p>")

      it "puts the selection at the end of the default block", ->
        handler.deleteAll()
        range = new Range($editable[0], window)
        range.paste("<b></b>")
        expect(clean($editable.html())).toEqual("<p><b></b></p>")

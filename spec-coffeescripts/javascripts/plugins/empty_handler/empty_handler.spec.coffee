# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "plugins/empty_handler/empty_handler", "core/helpers", "core/range"], ($, Handler, Helpers, Range) ->
  describe "EmptyHandler", ->
    $editable = api = null
    beforeEach ->
      $editable = addEditableFixture()
      $editable.html("<h1>Heading 1</h1><p>with some text</p>")
      Handler.api =
        el: $editable[0]
        getDefaultBlock: -> $("<p/>")
        getBlankRange: -> new Range($editable[0])
        isValid: -> true
        find: -> []
      Helpers.delegate(Handler.api, "getBlankRange()", "selectEndOfElement")

    afterEach ->
      $editable.remove()

    describe "#deleteAll", ->
      it "removes all content and replaces it with the default block", ->
        Handler.deleteAll()
        expect(clean($editable.html())).toEqual("<p></p>")

      it "puts the selection at the end of the default block", ->
        Handler.deleteAll()
        range = new Range($editable[0], window)
        range.insert("<b></b>")
        expect(clean($editable.html())).toEqual("<p><b></b></p>")

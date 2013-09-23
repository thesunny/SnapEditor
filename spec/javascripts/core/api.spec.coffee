# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "core/api", "core/range"], ($, API, Range) ->
  describe "API", ->
    api = $editable = null
    beforeEach ->
      $editable = addEditableFixture()
      api = new API(
        el: $editable[0]
        config:
          path: "/"
          widget: classname: "widget"
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

# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "core/editor", "core/helpers", "core/range"], ($, Editor, Helpers, Range) ->
  describe "Editor", ->
    $editable = editor = null
    beforeEach ->
      $editable = addEditableFixture()
      defaults =
        styles: []
        toolbar: items: []
        behaviours: []
        shortcuts: []
        cleaner:
          whitelist:
            "P": "p"
            "*": "P"
          ignore: []
        lang: "en",
        eraseHandler:
          delete: "delete"
        atomic:
          classname: "atomic"
        widget:
          classname: "widget"
      config = path: "spec/javascripts/support/assets"
      editor = new Editor($editable[0], defaults, config)

    afterEach ->
      $editable.remove()

    describe "#constructor", ->
      it "saves the element as a jQuery element", ->
        expect(editor.$el.attr).toBeDefined()

      it "creates an API", ->
        expect(editor.api).not.toBeNull()

    describe "#getContents", ->
      it "returns the contents of the editor", ->
        $editable.html("<p>this is just a test</p><p>yes it is</p>")
        expect(clean(editor.getContents())).toEqual("<p>this is just a test</p><p>yes it is</p>")

    describe "#getRange", ->
      $table = $td = null
      beforeEach ->
        $table = $('<table><tbody><tr><td id="td">cell</td><td>another</td></tr></tbody></table>').appendTo($editable)
        $td = $("#td")

      it "returns the selection when no element is given", ->
        expectedRange = new Range($editable[0], $td[0])
        expectedRange.selectEndOfElement($td[0])

        range = editor.getRange()
        range.insert("test")
        expect($td.html()).toEqual("celltest")

      it "returns the element's range when an element is given", ->
        range = editor.getRange($td[0])
        expect(range.getParentElement("tr")).not.toBeNull()

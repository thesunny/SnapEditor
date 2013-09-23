# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# NOTE: These tests only work in Webkit because the iframe loads immediately.
# In the other browsers, the load is delayed and falls out of the runtime of
# the tests.
require ["jquery.custom", "core/iframe"], ($, IFrame) ->
  describe "IFrame", ->
    $editable = null
    beforeEach ->
      $editable = addEditableFixture()

    afterEach ->
      $editable.remove()

    describe "#constructor", ->
      it "creates an iframe and returns it", ->
        iframe = new IFrame()
        expect($(iframe).tagName()).toEqual("iframe")

      it "writes the content to the document", ->
        iframe = new IFrame(
          write: ->
            @doc.write("<html><body><b>Hello</b></body></html>")
          load: ->
            expect($(@doc).find("b").length).toEqual(1)
        )
        $(iframe).appendTo($editable)

      it "performs the after write", ->
        iframe = new IFrame(
          write: ->
            @doc.write("<html><body><b>Hello</b></body></html>")
          afterWrite: ->
            @$b = $(@doc).find("b")
          load: ->
            expect(@$b.length).toEqual(1)
        )
        $(iframe).appendTo($editable)

      it "triggers events properly", ->
        iframe = new IFrame(
          write: ->
            @doc.write("<html><body><b>Hello</b></body></html>")
          load: ->
            clicked = false
            $(@doc).find("b").on("click", -> clicked = true)
            $(@doc).find("b").trigger("click")
            expect(clicked).toBeTruthy()
        )
        $(iframe).appendTo($editable)

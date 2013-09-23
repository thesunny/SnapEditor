# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# NOTE: These tests only work in Webkit because the iframe loads immediately.
# In the other browsers, the load is delayed and falls out of the runtime of
# the tests.
require ["jquery.custom", "core/iframe.snapeditor"], ($, IFrame) ->
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

      it "sets the class", ->
        iframe = new IFrame(
          class: "frame"
          load: -> expect($(this).hasClass("frame")).toBeTruthy()
        )
        $(iframe).appendTo($editable)

      it "sets the content", ->
        iframe = new IFrame(
          contents: "<b>hello</b>"
          load: -> expect(@el.innerHTML).toEqual("<b>hello</b>")
        )
        $(iframe).appendTo($editable)

      it "sets the content class", ->
        iframe = new IFrame(
          contentClass: "editable"
          load: -> expect($(@el).hasClass("editable")).toBeTruthy()
        )
        $(iframe).appendTo($editable)

      it "triggers events properly", ->
        iframe = new IFrame(
          contents: "<b>hello</b>"
          load: ->
            clicked = false
            $(@el).find("b").on("click", -> clicked = true)
            $(@doc).find("b").trigger("click")
            expect(clicked).toBeTruthy()
        )
        $(iframe).appendTo($editable)

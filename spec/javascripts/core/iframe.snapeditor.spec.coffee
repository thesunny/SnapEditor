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
        # WARNING:
        # IE8 returns <B>hello</B> so we make ie8 happy by giving it that
        # option. Later we may wish to look for a way to prevent IE from doing
        # that.
        s = if isIE8 then "<B>hello</B>" else "<b>hello</b>"
        iframe = new IFrame(
          contents: "<b>hello</b>"
          load: -> expect(@el.innerHTML).toEqual(s)
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

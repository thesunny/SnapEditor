# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery", "core/toolbar/toolbar.floating.displayer"], ($, Displayer) ->
  describe "Toolbar.Floating.Displayer", ->
    $container = displayer = null
    beforeEach ->
      $container = $("<div/>").prependTo("body")
      $el = $("<div>text</div>").appendTo($container)
      $toolbar = $('<div style="display:none">toolbar</div>').appendTo($container)
      editor = $("<div/>")
      editor.isValid = -> true
      displayer = new Displayer($toolbar, $el, editor)

    afterEach ->
      $container.remove()

    describe "#overlapSpaceFromElTop", ->
      it "returns 0 when there is enough space at the top", ->
        spyOn(displayer, "toolbarSize").andReturn({ y: 50 })
        spyOn(displayer, "elCoords").andReturn({ top: 200 })
        expect(displayer.overlapSpaceFromElTop()).toEqual(0)

      it "returns a positive number when there is overlapping", ->
        spyOn(displayer, "toolbarSize").andReturn({ y: 50 })
        spyOn(displayer, "elCoords").andReturn({ top: 25 })
        expect(displayer.overlapSpaceFromElTop()).toEqual(25)

    describe "#isCursorInOverlapSpace", ->
      it "returns true when the cursor is in the overlap space", ->
        spyOn(displayer, "cursorPosition").andReturn(110)
        spyOn(displayer, "elCoords").andReturn({ top: 100 })
        spyOn(displayer, "overlapSpaceFromElTop").andReturn(50)
        expect(displayer.isCursorInOverlapSpace()).toBeTruthy()

      it "returns false when the cursor is not in the overlap space", ->
        spyOn(displayer, "cursorPosition").andReturn(160)
        spyOn(displayer, "elCoords").andReturn({ top: 100 })
        spyOn(displayer, "overlapSpaceFromElTop").andReturn(50)
        expect(displayer.isCursorInOverlapSpace()).toBeFalsy()

      it "returns false when there is no cursor", ->
        spyOn(displayer.editor, "isValid").andReturn(false)
        expect(displayer.isCursorInOverlapSpace()).toBeFalsy()

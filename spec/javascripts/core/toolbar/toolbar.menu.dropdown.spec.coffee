# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "core/helpers", "core/toolbar/toolbar.menu.dropdown"], ($, Helpers, Dropdown) ->
  describe "Toolbar.Dropdown", ->
    dropdown = null
    beforeEach ->
      dropdown = new Dropdown({}, { relEl: $("</div>")})
      dropdown.$el = $("<div/>")

    describe "#getStyles", ->
      beforeEach ->
        spyOn(dropdown.$relEl, "getCoordinates").andReturn(
          top: 100
          bottom: 200
          left: 300
          right: 350
        )
        spyOn(Helpers, "getWindowBoundary").andReturn(
          top: 0
          bottom: 250
          left: 0
          right: 400
        )
        spyOn(dropdown.$el, "getSize")

      describe "below", ->
        it "fits", ->
          dropdown.$el.getSize.andReturn(x: 5, y: 5)
          expect(dropdown.getStyles()).toEqual(top: 200, left: 300)

        it "doesn't fit to the right", ->
          dropdown.$el.getSize.andReturn(x: 200, y: 5)
          expect(dropdown.getStyles()).toEqual(top: 200, left: 200)

      describe "above", ->
        it "fits", ->
          dropdown.$el.getSize.andReturn(x: 5, y: 75)
          expect(dropdown.getStyles()).toEqual(top: 25, left: 300)

        it "doesn't fit to the right", ->
          dropdown.$el.getSize.andReturn(x: 200, y: 75)
          expect(dropdown.getStyles()).toEqual(top: 25, left: 200)

      describe "side", ->
        it "fits", ->
          dropdown.$el.getSize.andReturn(x: 5, y: 100)
          expect(dropdown.getStyles()).toEqual(top: 0, left: 300)

        it "doesn't fit to the right", ->
          dropdown.$el.getSize.andReturn(x: 200, y: 150)
          expect(dropdown.getStyles()).toEqual(top: 0, left: 100)

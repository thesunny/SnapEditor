require ["jquery.custom", "plugins/autoscroll/autoscroll"], ($, Autoscroll) ->
  describe "Autoscroll", ->
    describe "#autoscroll", ->
      api = null
      beforeEach ->
        api =
          win: window
          getCoordinates: null
          isValid: -> true

      it "scrolls to the top line if the cursor is above the top line", ->
        spyOn(api, "getCoordinates").andReturn(top: 5)
        spyOn(window, "scrollTo")
        Autoscroll.autoscroll(api: api)
        expect(window.scrollTo).toHaveBeenCalledWith(0, -45)

      it "scrolls to the bottom line if the cursor is below the bottom line", ->
        windowSize = $(window).getSize()
        spyOn(api, "getCoordinates").andReturn(bottom: windowSize.y - 5)
        spyOn(window, "scrollTo")
        Autoscroll.autoscroll(api: api)
        expect(window.scrollTo).toHaveBeenCalledWith(0, 45)

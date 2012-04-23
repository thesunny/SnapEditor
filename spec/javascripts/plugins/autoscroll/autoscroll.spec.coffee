require ["jquery.custom", "plugins/autoscroll/autoscroll"], ($, Autoscroll) ->
  describe "Autoscroll", ->
    describe "#autoscroll", ->
      api = autoscroll = null
      beforeEach ->
        api = getCoordinates: null
        autoscroll = new Autoscroll()
        autoscroll.api = api

      it "scrolls to the top line if the cursor is above the top line", ->
        spyOn(api, "getCoordinates").andReturn(top: 5)
        spyOn(window, "scrollTo")
        autoscroll.autoscroll()
        expect(window.scrollTo).toHaveBeenCalledWith(0, -45)

      it "scrolls to the bottom line if the cursor is below the bottom line", ->
        windowSize = $(window).getSize()
        spyOn(api, "getCoordinates").andReturn(bottom: windowSize.y - 5)
        spyOn(window, "scrollTo")
        autoscroll.autoscroll()
        expect(window.scrollTo).toHaveBeenCalledWith(0, 45)

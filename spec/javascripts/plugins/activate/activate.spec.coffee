require ["jquery.custom", "plugins/activate/activate"], ($, Activate) ->
  describe "Activate", ->

    api = null
    beforeEach ->
      api = $("<div/>")
      api.activate = ->

    describe "modules", ->
      it "includes browser specific functions", ->
        expect(-> Activate.addActivateEvents(api)).not.toThrow()

    describe "#click", ->
      it "triggers snapeditor.activate_click", ->
        spyOn(api, "trigger")
        Activate.click(api)
        expect(api.trigger).toHaveBeenCalledWith("snapeditor.activate_click")

    describe "#activate", ->
      it "activates the editor", ->
        spyOn(api, "activate")
        Activate.activate(api)
        expect(api.activate).toHaveBeenCalled()

      it "listens to snapeditor.deactivate", ->
        spyOn(Activate, "deactivate")
        Activate.activate(api)
        api.trigger("snapeditor.deactivate")
        expect(Activate.deactivate).toHaveBeenCalledWith(api)

    describe "#deactivate", ->
      it "stops listening to snapeditor.deactivate", ->
        spyOn(Activate, "addActivateEvents")
        Activate.activate(api)
        Activate.deactivate(api)
        spyOn(Activate, "deactivate")
        api.trigger("snapeditor.deactivate")
        expect(Activate.deactivate).not.toHaveBeenCalled()

      it "adds the activate events", ->
        spyOn(Activate, "addActivateEvents")
        Activate.deactivate(api)
        expect(Activate.addActivateEvents).toHaveBeenCalled()

    describe "#isLink", ->
      it "returns true if the element is a link", ->
        expect(Activate.isLink($("<a/>"))).toBeTruthy()

      it "returns true if the element is inside link", ->
        $a = $("<a/>")
        $span = $("<span/>").appendTo($a)
        expect(Activate.isLink($span)).toBeTruthy()

      it "returns false otherwise", ->
        expect(Activate.isLink($("<div/>"))).toBeFalsy()

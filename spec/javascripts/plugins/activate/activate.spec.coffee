require ["jquery.custom", "plugins/activate/activate"], ($, A) ->
  describe "Activate", ->

    activate = api = null
    beforeEach ->
      activate = window.SnapEditor.internalPlugins.activate
      api = $("<div/>")
      api.activate = ->
      api.plugins = activate: activate

    describe "modules", ->
      it "includes browser specific functions", ->
        expect(-> activate.addActivateEvents(api)).not.toThrow()

    describe "#click", ->
      it "triggers snapeditor.activate_click", ->
        spyOn(api, "trigger")
        activate.click(api)
        expect(api.trigger).toHaveBeenCalledWith("snapeditor.activate_click")

    describe "#activate", ->
      it "activates the editor", ->
        $target = $("<div/>")
        spyOn(api, "activate")
        spyOn(api, "on")
        activate.activate(api)
        expect(api.activate).toHaveBeenCalled()

      it "listens to deactivate.editor", ->
        $target = $("<div/>")
        spyOn(api, "activate")
        spyOn(api, "on")
        activate.activate(api)
        expect(api.on).toHaveBeenCalledWith("snapeditor.deactivate", activate.deactivate)

    describe "#deactivate", ->
      it "stops listening to deactivate.editor", ->
        spyOn(api, "off")
        spyOn(activate, "addActivateEvents")
        activate.deactivate(api: api)
        expect(api.off).toHaveBeenCalledWith("snapeditor.deactivate", activate.deactivate)

      it "adds the activate events", ->
        spyOn(api, "off")
        spyOn(activate, "addActivateEvents")
        activate.deactivate(api: api)
        expect(activate.addActivateEvents).toHaveBeenCalled()

    describe "#isLink", ->
      it "returns true if the element is a link", ->
        expect(activate.isLink($("<a/>"))).toBeTruthy()

      it "returns true if the element is inside link", ->
        $a = $("<a/>")
        $span = $("<span/>").appendTo($a)
        expect(activate.isLink($span)).toBeTruthy()

      it "returns false otherwise", ->
        expect(activate.isLink($("<div/>"))).toBeFalsy()

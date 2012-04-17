describe "Activate", ->
  required = ["cs!plugins/activate/activate"]

  describe "modules", ->
    ait "includes browser specific functions", required, (Activate) ->
      activate = new Activate()
      activate.api = { $el: $("<div/>") }
      expect(-> activate.addActivateEvents()).not.toThrow()

  describe "#register", ->
    ait "stores the api", required, (Activate) ->
      activate = new Activate()
      spyOn(activate, "addActivateEvents")
      activate.register("api")
      expect(activate.api).toEqual("api")

    ait "adds the activate events", required, (Activate) ->
      activate = new Activate()
      spyOn(activate, "addActivateEvents")
      activate.register("api")
      expect(activate.addActivateEvents).toHaveBeenCalled()

  describe "#click", ->
    ait "triggers click.activate", required, (Activate) ->
      activate = new Activate()
      activate.api = { trigger: null }
      spyOn(activate.api, "trigger")
      activate.click({})
      expect(activate.api.trigger).toHaveBeenCalledWith("click.activate")

  describe "#activate", ->
    ait "activates the editor", required, (Activate) ->
      $target = $("<div/>")
      activate = new Activate()
      activate.api = { activate: null, on: null }
      spyOn(activate.api, "activate")
      spyOn(activate.api, "on")
      activate.activate(target: $target)
      expect(activate.api.activate).toHaveBeenCalled()

    ait "listens to deactivate.editor", required, (Activate) ->
      $target = $("<div/>")
      activate = new Activate()
      activate.api = { activate: null, on: null }
      spyOn(activate.api, "activate")
      spyOn(activate.api, "on")
      activate.activate(target: $target)
      expect(activate.api.on).toHaveBeenCalledWith("deactivate.editor", activate.deactivate)

  describe "#deactivate", ->
    ait "stops listening to deactivate.editor", required, (Activate) ->
      activate = new Activate()
      activate.api = { off: null }
      spyOn(activate.api, "off")
      spyOn(activate, "addActivateEvents")
      activate.deactivate()
      expect(activate.api.off).toHaveBeenCalledWith("deactivate.editor", activate.deactivate)

    ait "adds the activate events", required, (Activate) ->
      activate = new Activate()
      activate.api = { off: null }
      spyOn(activate.api, "off")
      spyOn(activate, "addActivateEvents")
      activate.deactivate()
      expect(activate.addActivateEvents).toHaveBeenCalled()

  describe "#isLink", ->
    ait "returns true if the element is a link", required, (Activate) ->
      activate = new Activate()
      expect(activate.isLink($("<a/>"))).toBeTruthy()

    ait "returns true if the element is inside link", required, (Activate) ->
      $a = $("<a/>")
      $span = $("<span/>").appendTo($a)
      activate = new Activate()
      expect(activate.isLink($span)).toBeTruthy()

    ait "returns false otherwise", required, (Activate) ->
      activate = new Activate()
      expect(activate.isLink($("<div/>"))).toBeFalsy()

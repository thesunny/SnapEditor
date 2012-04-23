unless isIE
  describe "Activate.Others", ->
    required = ["plugins/activate/activate.others", "core/helpers"]

    Activate = $editable = null
    beforeEach ->
      $editable = addEditableFixture()
      class Activate
        api: { el: $editable[0], select: null },
        click: null,
        activate: null

    afterEach ->
      $editable.remove()

    describe "#addActivateEvents", ->
      ait "adds mousedown and mouseup events", required, (Module, Helpers) ->
        Helpers.include(Activate, Module)

        activate = new Activate()
        spyOn(activate, "onmousedown")
        spyOn(activate, "onmouseup")
        activate.addActivateEvents()
        $(activate.api.el).trigger("mousedown")
        $(activate.api.el).trigger("mouseup")
        expect(activate.onmousedown).toHaveBeenCalled()
        expect(activate.onmouseup).toHaveBeenCalled()

      ait "listens to mousedown and mouseup only once", required, (Module, Helpers) ->
        Helpers.include(Activate, Module)

        activate = new Activate()
        spyOn(activate, "onmousedown")
        spyOn(activate, "onmouseup")
        activate.addActivateEvents()

        $(activate.api.el).trigger("mousedown")
        $(activate.api.el).trigger("mouseup")
        $(activate.api.el).trigger("mousedown")
        $(activate.api.el).trigger("mouseup")

        expect(activate.onmousedown.callCount).toEqual(1)
        expect(activate.onmouseup.callCount).toEqual(1)

    describe "#onmousedown", ->
      ait "triggers click.activate when the target is not a link", required, (Module, Helpers) ->
        Helpers.include(Activate, Module)

        activate = new Activate()
        activate.isLink = (el) -> false
        spyOn(activate, "click")
        activate.onmousedown(target: "target")
        expect(activate.click).toHaveBeenCalled()

      ait "does nothing when the target is a link", required, (Module, Helpers) ->
        Helpers.include(Activate, Module)

        activate = new Activate()
        activate.isLink = (el) -> true
        spyOn(activate, "click")
        activate.onmousedown(target: "target")
        expect(activate.click).not.toHaveBeenCalled()

    describe "#onmouseup", ->
      ait "selects the target if an image is clicked", required, (Module, Helpers) ->
        Helpers.include(Activate, Module)

        $target = $("<img/>")

        activate = new Activate()
        activate.isLink = (el) -> false
        spyOn(activate.api, "select")
        spyOn(activate, "activate")
        activate.onmouseup(target: $target)
        expect(activate.api.select).toHaveBeenCalledWith($target)

      ait "does not select the target if an image is not clicked", required, (Module, Helpers) ->
        Helpers.include(Activate, Module)

        activate = new Activate()
        activate.isLink = (el) -> false
        spyOn(activate.api, "select")
        spyOn(activate, "activate")
        activate.onmouseup(target: $("<div/>"))
        expect(activate.api.select).not.toHaveBeenCalled()

      ait "activates the editor when the target is not a link", required, (Module, Helpers) ->
        Helpers.include(Activate, Module)

        activate = new Activate()
        activate.isLink = (el) -> false
        spyOn(activate, "activate")
        activate.onmouseup(target: $("<div/>"))
        expect(activate.activate).toHaveBeenCalled()

      ait "does nothing when the target is a link", required, (Module, Helpers) ->
        Helpers.include(Activate, Module)

        activate = new Activate()
        activate.isLink = (el) -> true
        spyOn(activate, "activate")
        activate.onmouseup(target: $("<div/>"))
        expect(activate.activate).not.toHaveBeenCalled()

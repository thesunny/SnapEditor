if isIE
  describe "Activate.IE", ->
    required = ["plugins/activate/activate.ie", "jquery.custom", "core/helpers"]

    Activate = $editable = null
    beforeEach ->
      $editable = addEditableFixture()
      class Activate
        api: { el: $editable[0], range: null, select: null },
        click: null,
        activate: null

    afterEach ->
      $editable.remove()

    describe "#addActivateEvents", ->
      ait "adds mouseup events", required, (Module, $, Helpers) ->
        Helpers.include(Activate, Module)

        activate = new Activate()
        spyOn(activate, "onmouseup")
        activate.addActivateEvents()

        $(activate.api.el).trigger("mouseup")
        expect(activate.onmouseup).toHaveBeenCalled()

      ait "listens to mouseup only once", required, (Module, $, Helpers) ->
        Helpers.include(Activate, Module)

        activate = new Activate()
        spyOn(activate, "onmouseup")
        activate.addActivateEvents()

        $(activate.api.el).trigger("mouseup")
        $(activate.api.el).trigger("mouseup")

        expect(activate.onmouseup.callCount).toEqual(1)

    describe "#onmouseup", ->
      describe "target is not a link", ->
        ait "saves the range and reselects it when the target is not an image", required, (Module, $, Helpers) ->
          Helpers.include(Activate, Module)

          range = { select: null }
          spyOn(range, "select")

          activate = new Activate()
          activate.isLink = (el) -> false
          spyOn(activate, "click")
          spyOn(activate, "activate")
          spyOn(activate.api, "range").andReturn(range)

          activate.onmouseup(target: $("<div/>")[0])
          expect(activate.api.range).toHaveBeenCalled()
          expect(range.select).toHaveBeenCalled()

        ait "selects the target when the target is an image", required, (Module, $, Helpers) ->
          Helpers.include(Activate, Module)

          $target = $("<img/>")

          activate = new Activate()
          activate.isLink = (el) -> false
          spyOn(activate, "click")
          spyOn(activate, "activate")
          spyOn(activate.api, "select")

          activate.onmouseup(target: $target[0])
          expect(activate.api.select).toHaveBeenCalledWith($target[0])

        ait "triggers click.activate and activates the editor", required, (Module, $, Helpers) ->
          Helpers.include(Activate, Module)

          range = { select: null }
          spyOn(range, "select")

          activate = new Activate()
          activate.isLink = (el) -> false
          spyOn(activate, "click")
          spyOn(activate, "activate")
          spyOn(activate.api, "range").andReturn(range)

          activate.onmouseup(target: $("<div/>")[0])
          expect(activate.click).toHaveBeenCalled()
          expect(activate.activate).toHaveBeenCalled()

      describe "target is a link", ->
        ait "does nothing", required, (Module, $, Helpers) ->
          Helpers.include(Activate, Module)

          activate = new Activate()
          activate.isLink = (el) -> true
          spyOn(activate, "click")
          spyOn(activate, "activate")

          activate.onmouseup(target: $("<div/>")[0])
          expect(activate.click).not.toHaveBeenCalled()
          expect(activate.activate).not.toHaveBeenCalled()

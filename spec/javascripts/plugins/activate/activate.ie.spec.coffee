if isIE
  require ["jquery.custom", "core/helpers", "plugins/activate/activate.ie"], ($, Helpers, IE) ->
    describe "Activate.IE", ->
      activate = api = null
      beforeEach ->
        activate =
          click: ->
          activate: ->
          isLink: -> false
        Helpers.extend(activate, IE)
        api = $("<div/>")
        api.select = ->
        api.config = plugins: activate: activate

      describe "#addActivateEvents", ->
        it "adds mouseup events", ->
          spyOn(activate, "onmouseup")
          activate.addActivateEvents(api)

          api.trigger("snapeditor.mouseup")
          expect(activate.onmouseup).toHaveBeenCalled()

        it "listens to mouseup only once", ->
          spyOn(activate, "onmouseup")
          activate.addActivateEvents(api)

          api.trigger("snapeditor.mouseup")
          api.trigger("snapeditor.mouseup")

          expect(activate.onmouseup.callCount).toEqual(1)

      describe "#onmouseup", ->
        describe "target is not a link", ->
          it "selects the target when the target is an image", ->
            $target = $("<img/>")
            spyOn(activate, "click")
            spyOn(activate, "activate")
            spyOn(api, "select")

            activate.onmouseup(api: api, target: $target[0])
            expect(api.select).toHaveBeenCalledWith($target[0])

          it "triggers click.activate and activates the editor", ->
            spyOn(activate, "click")
            spyOn(activate, "activate")
            activate.onmouseup(api: api, target: $("<div/>")[0])
            expect(activate.click).toHaveBeenCalled()
            expect(activate.activate).toHaveBeenCalled()

        describe "target is a link", ->
          it "does nothing", ->
            spyOn(activate, "isLink").andReturn(true)
            spyOn(activate, "click")
            spyOn(activate, "activate")
            activate.onmouseup(api: api, target: $("<div/>")[0])
            expect(activate.click).not.toHaveBeenCalled()
            expect(activate.activate).not.toHaveBeenCalled()

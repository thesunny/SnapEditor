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
        api.el = $("<div/>")[0]
        api.select = ->
        api.plugins = activate: activate

      describe "#addActivateEvents", ->
        it "adds mouseup events", ->
          spyOn(activate, "onmouseup")
          activate.addActivateEvents(api)

          $(api.el).trigger("mouseup")
          expect(activate.onmouseup).toHaveBeenCalled()

        it "listens to mouseup only once", ->
          spyOn(activate, "onmouseup")
          activate.addActivateEvents(api)

          $(api.el).trigger("mouseup")
          $(api.el).trigger("mouseup")

          expect(activate.onmouseup.callCount).toEqual(1)

      describe "#onmouseup", ->
        event = null
        beforeEach ->
          event =
            data: api: api
            target: $("<div/>")[0]

        describe "target is not a link", ->
          it "selects the target when the target is an image", ->
            spyOn(activate, "click")
            spyOn(activate, "activate")
            spyOn(api, "select")

            event.target = $("<img/>")[0]
            activate.onmouseup(event)
            expect(api.select).toHaveBeenCalledWith(event.target)

          it "triggers click.activate and activates the editor", ->
            spyOn(activate, "click")
            spyOn(activate, "activate")
            activate.onmouseup(event)
            expect(activate.click).toHaveBeenCalled()
            expect(activate.activate).toHaveBeenCalled()

        describe "target is a link", ->
          it "does nothing", ->
            spyOn(activate, "isLink").andReturn(true)
            spyOn(activate, "click")
            spyOn(activate, "activate")
            activate.onmouseup(event)
            expect(activate.click).not.toHaveBeenCalled()
            expect(activate.activate).not.toHaveBeenCalled()

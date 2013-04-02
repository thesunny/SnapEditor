unless isIE
  require ["jquery.custom", "core/helpers", "plugins/activate/activate.others"], ($, Helpers, Others) ->
    describe "Activate.Others", ->
      api = activate = null
      beforeEach ->
        activate =
          click: ->
          activate: ->
          isLink: -> false
        Helpers.extend(activate, Others)
        api = $("<div/>")
        api.el = $("<div/>")[0]
        api.select = ->
        api.config = plugins: activate: activate

      describe "#addActivateEvents", ->
        it "adds mousedown and mouseup events", ->
          spyOn(activate, "onmousedown")
          spyOn(activate, "onmouseup")
          activate.addActivateEvents(api)
          $(api.el).trigger("mousedown")
          $(api.el).trigger("mouseup")
          expect(activate.onmousedown).toHaveBeenCalled()
          expect(activate.onmouseup).toHaveBeenCalled()

        it "listens to mousedown and mouseup only once", ->
          spyOn(activate, "onmousedown").andCallThrough()
          spyOn(activate, "onmouseup").andCallThrough()
          activate.addActivateEvents(api)

          $(api.el).trigger("mousedown")
          $(api.el).trigger("mouseup")
          $(api.el).trigger("mousedown")
          $(api.el).trigger("mouseup")

          expect(activate.onmousedown.callCount).toEqual(1)
          expect(activate.onmouseup.callCount).toEqual(1)

      describe "#onmousedown", ->
        event = null
        beforeEach ->
          event =
            data:
              api: api
            target: "target"

        it "triggers click.activate when the target is not a link", ->
          activate.isLink = (el) -> false
          spyOn(activate, "click")
          activate.onmousedown(event)
          expect(activate.click).toHaveBeenCalled()

        it "does nothing when the target is a link", ->
          spyOn(activate, "isLink").andReturn(true)
          spyOn(activate, "click")
          activate.onmousedown(event)
          expect(activate.click).not.toHaveBeenCalled()

      describe "#onmouseup", ->
        event = null
        beforeEach ->
          event =
            data:
              api: api
            target: $("<div/>")[0]

        it "selects the target if an image is clicked", ->
          spyOn(api, "select")
          spyOn(activate, "activate")
          event.target = $("<img/>")[0]
          activate.onmouseup(event)
          expect(api.select).toHaveBeenCalledWith(event.target)

        it "does not select the target if an image is not clicked", ->
          spyOn(api, "select")
          spyOn(activate, "activate")
          activate.onmouseup(event)
          expect(api.select).not.toHaveBeenCalled()

        it "activates the editor when the target is not a link", ->
          spyOn(activate, "activate")
          activate.onmouseup(event)
          expect(activate.activate).toHaveBeenCalled()

        it "does nothing when the target is a link", ->
          spyOn(activate, "isLink").andReturn(true)
          spyOn(activate, "activate")
          activate.onmouseup(event)
          expect(activate.activate).not.toHaveBeenCalled()

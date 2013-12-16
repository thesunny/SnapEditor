# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
if isIE
  require ["jquery.custom", "core/helpers", "plugins/activate/activate.ie"], ($, Helpers, IE) ->
    describe "Activate.IE", ->
      activate = api = null
      beforeEach ->
        activate =
          click: ->
          shouldActivate: -> true
          finishActivate: ->
          isLink: -> false
        Helpers.extend(activate, IE)
        api = $("<div/>")
        api.el = $("<div/>")[0]
        api.select = ->

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
          event = target: $("<div/>")[0]

        describe "target is not a link", ->
          it "selects the target when the target is an image", ->
            spyOn(activate, "click")
            spyOn(activate, "finishActivate")
            spyOn(api, "select")

            event.target = $("<img/>")[0]
            activate.onmouseup(event, api)
            expect(api.select).toHaveBeenCalledWith(event.target)

          it "triggers snapeditor.activate_click and activates the editor", ->
            spyOn(api, "trigger")
            spyOn(activate, "finishActivate")
            activate.onmouseup(event, api)
            expect(api.trigger).toHaveBeenCalledWith("snapeditor.activate_click")
            expect(activate.finishActivate).toHaveBeenCalled()

        describe "target is a link", ->
          it "does nothing", ->
            spyOn(activate, "shouldActivate").andReturn(false)
            spyOn(activate, "isLink").andReturn(true)
            spyOn(activate, "click")
            spyOn(activate, "finishActivate")
            activate.onmouseup(event, api)
            expect(activate.click).not.toHaveBeenCalled()
            expect(activate.finishActivate).not.toHaveBeenCalled()

# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
if isIE
  require ["jquery.custom", "plugins/editable/editable.ie"], ($, IE) ->
    describe "Editable.IE", ->
      $div = api = null
      beforeEach ->
        # If the div is not in the DOM, IE craps out.
        $div = $("<div/>").prepend("body")
        api =
          el: $div[0]
          config: plugins: editable: IE

      afterEach ->
        $div.remove()

      describe "#start", ->
        it "prevents the image resize handlers from working", ->
          spyOn(IE, "preventResize")
          IE.start(api)
          console.log 1

          # NOTE: The event handler is attached using native JavaScript. Hence,
          # we need to fire the event using native JavaScript.
          api.el.fireEvent("onresizestart", document.createEventObject())
          expect(IE.preventResize).toHaveBeenCalled()

        it "makes the el editable", ->
          IE.start(api)
          expect($(api.el).attr("contenteditable")).toEqual("true")

      describe "#deactivateBrowser", ->
        it "detaches the onresizestart event handler", ->
          spyOn(IE, "preventResize")
          IE.start(api)
          IE.deactivateBrowser(api)

          # NOTE: The event handler is attached using native JavaScript. Hence,
          # we need to fire the event using native JavaScript.
          api.el.fireEvent("onresizestart", document.createEventObject())
          expect(IE.preventResize).not.toHaveBeenCalled()

      describe "#preventResize", ->
        it "sets the return value to false", ->
          e = returnValue: true
          IE.preventResize(e)
          expect(e.returnValue).toBeFalsy()

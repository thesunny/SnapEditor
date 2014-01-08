# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# NOTE: Unfortunately, spies don't work on bound functions. Hence, in order to
# check that the events are triggering properly, we need to actually check the
# results of the handlers. This means that there will be dependencies between
# functions when testing.
require ["jquery.custom", "core/data_action_handler", "core/helpers"], ($, Handler, Helpers) ->
  describe "DataActionHandler", ->
    $el = handler = null
    beforeEach ->
      $el = $('
        <div>
          <select id="select_no_event"><option value="1" selected="selected">1</option><option value="2">2</option></select>
          <select id="select_event" data-action="select"><option value="1" selected="selected">1</option><option value="2">2</option></select>
          <input id="button_no_event" type="button" />
          <input id="button_event" type="button" data-action="button" />
          <input id="text_no_event" type="text" />
          <input id="text_event" type="text" data-action="text" />
        </div>
      ').prependTo("body")
      api = $("<div/>")
      api.editor = {}
      api.el = $el[0]
      api.isValid = ->
      spyOn(api, "trigger")
      handler = new Handler($el, api)
      handler.activate()

    afterEach ->
      $el.remove()

    describe "#activate", ->
      it "listens to change events on <select> with the 'data-action' attribute", ->
        $("#select_no_event").trigger("change")
        $("#select_event").trigger("change")
        expect(handler.api.trigger.callCount).toEqual(1)

      it "listens to the mousedown event", ->
        expect(handler.isClick).toBeUndefined()
        $el.trigger("mousedown")
        expect(handler.isClick).toBeTruthy()

      it "listens to the mouseup event", ->
        expect(handler.isClick).toBeUndefined()
        $el.trigger("mouseup")
        expect(handler.isClick).toBeFalsy()

      it "listens to the keypress event", ->
        $("#button_event").trigger("keypress")
        expect(handler.api.trigger).toHaveBeenCalled()

    describe "#mouseup", ->
      it "does not trigger the event if the click did not start on the button", ->
        $("#button_event").trigger("mouseup")
        expect(handler.api.trigger).not.toHaveBeenCalled()

      it "does not trigger the event if the button does not have a data-action attribute", ->
        handler.isClick = true
        $("#button_no_event").trigger("mouseup")
        expect(handler.api.trigger).not.toHaveBeenCalled()

      it "triggers the event if the button has a data-action attribute", ->
        handler.isClick = true
        handler.mouseup(
          target: $("#button_event")[0]
          which: Helpers.buttons.left
          preventDefault: ->
          stopPropagation: ->
        )
        expect(handler.api.trigger).toHaveBeenCalledWith("button", $("#button_event")[0])

    describe "#change", ->
      it "does not trigger the event if the target does not have a data-action attribute", ->
        $("#select_no_event").trigger("change")
        expect(handler.api.trigger).not.toHaveBeenCalled()

      it "triggers the event if the target has a data-action attribute", ->
        $("#select_event").trigger("change")
        expect(handler.api.trigger).toHaveBeenCalledWith("select", "1")

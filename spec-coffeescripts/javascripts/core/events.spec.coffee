# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# NOTE: This is more like an integration test because there's not much point
# unit testing ecah function separately. For instance, when binding, in order
# to test if it worked, you would have to trigger the event.
describe "Events", ->
  required = ["core/events", "core/helpers"]

  Events = null
  beforeEach ->
    class Events

  describe "#get$eventEl", ->
    ait "returns an element", required, (Module, Helpers) ->
      Helpers.include(Events, Module)

      events = new Events()
      $el = events.get$eventEl()
      expect($el).not.toBeNull()
      expect($el[0].nodeType).toEqual(1)

  describe "events work properly", ->
    ait "binds and triggers", required, (Module, Helpers) ->
      Helpers.include(Events, Module)

      triggerValue = false
      triggerFn = (e) -> triggerValue = true

      events = new Events()
      events.on("test.trigger", triggerFn)
      events.trigger("test.trigger")
      expect(triggerValue).toBeTruthy()

    ait "triggers the handler when the bind is namespaced but the trigger is not", required, (Module, Helpers) ->
      Helpers.include(Events, Module)

      triggerValue = false
      triggerFn = (e) -> triggerValue = true

      events = new Events()
      events.on("test.trigger", triggerFn)
      events.trigger("test")
      expect(triggerValue).toBeTruthy()

    ait "does not trigger the handler when the bind is not namespaced but the trigger is", required, (Module, Helpers) ->
      Helpers.include(Events, Module)

      triggerValue = false
      triggerFn = (e) -> triggerValue = true

      events = new Events()
      events.on("test", triggerFn)
      events.trigger("test.trigger")
      expect(triggerValue).toBeFalsy()

    ait "unbinds", required, (Module, Helpers) ->
      Helpers.include(Events, Module)

      triggerValue = false
      triggerFn = (e) -> triggerValue = true

      events = new Events()
      events.on("test.trigger", triggerFn)
      events.off("test.trigger", triggerFn)
      events.trigger("test.trigger")
      expect(triggerValue).toBeFalsy()

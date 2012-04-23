# NOTE: Unfortunately, spies don't work on bound functions. Hence, in order to
# check that the events are triggering properly, we need to actually check the
# results of the handlers. This means that there will be dependencies between
# functions when testing.
describe "DataActionHandler", ->
  required = ["core/data_action_handler"]

  $el = namespace = null
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
    namespace = "test"

  afterEach ->
    $el.remove()

  describe "#constructor", ->
    ait "listens to change events on <select> with the 'data-action' attribute", required, (Handler) ->
      api = { trigger: null }
      spyOn(api, "trigger")
      handler = new Handler($el, api, namespace)
      $("#select_no_event").trigger("change")
      $("#select_event").trigger("change")
      expect(api.trigger.callCount).toEqual(1)

    ait "listens to the mousedown event", required, (Handler) ->
      handler = new Handler($el, {}, namespace)
      expect(handler.isClick).toBeUndefined()
      $el.trigger("mousedown")
      expect(handler.isClick).toBeTruthy()

    ait "listens to the mouseup event", required, (Handler) ->
      handler = new Handler($el, {}, namespace)
      expect(handler.isClick).toBeUndefined()
      $el.trigger("mouseup")
      expect(handler.isClick).toBeFalsy()

    ait "listens to the keypress event", required, (Handler) ->
      api = { trigger: null }
      spyOn(api, "trigger")
      handler = new Handler($el, api, namespace)
      $("#button_event").trigger("keypress")
      expect(api.trigger).toHaveBeenCalled()

  describe "#click", ->
    ait "sets isClick to false", required, (Handler) ->
      handler = new Handler($el, {}, namespace)
      expect(handler.isClick).toBeUndefined()
      $("#button_event").trigger("mouseup")
      expect(handler.isClick).toBeFalsy()

    ait "does not trigger the event if the click did not start on the button", required, (Handler) ->
      api = { trigger: null }
      spyOn(api, "trigger")
      handler = new Handler($el, api, namespace)
      $("#button_event").trigger("mouseup")
      expect(api.trigger).not.toHaveBeenCalled()

    ait "does not trigger the event if the button does not have a data-action attribute", required, (Handler) ->
      api = { trigger: null }
      spyOn(api, "trigger")
      handler = new Handler($el, api, namespace)
      handler.isClick = true
      $("#button_no_event").trigger("mouseup")
      expect(api.trigger).not.toHaveBeenCalled()

    ait "triggers the event if the button has a data-action attribute", required, (Handler) ->
      api = { trigger: null }
      spyOn(api, "trigger")
      handler = new Handler($el, api, namespace)
      handler.isClick = true
      $("#button_event").trigger("mouseup")
      expect(api.trigger).toHaveBeenCalledWith("button.test", $("#button_event")[0])

  describe "#change", ->
    ait "does not trigger the event if the target does not have a data-action attribute", required, (Handler) ->
      api = { trigger: null }
      spyOn(api, "trigger")
      handler = new Handler($el, api, namespace)
      $("#select_no_event").trigger("change")
      expect(api.trigger).not.toHaveBeenCalled()

    ait "triggers the event if the target has a data-action attribute", required, (Handler) ->
      api = { trigger: null }
      spyOn(api, "trigger")
      handler = new Handler($el, api, namespace)
      $("#select_event").trigger("change")
      expect(api.trigger).toHaveBeenCalledWith("select.test", "1")

describe "Toolbar", ->
  required = ["cs!plugins/toolbar/toolbar"]

  api = plugin = null
  beforeEach ->
    api = $("<div/>")
    plugin =
      register: (api) ->,
      getDefaultToolbar: -> "TestButton"
      getToolbar: -> TestButton: "html"

  describe "#addPlugin", ->
    ait "throws an error if there is no #getDefaultToolbar()", required, (Toolbar) ->
      plugin.getDefaultToolbar = null
      toolbar = new Toolbar()
      expect(-> toolbar.addPlugin(plugin)).toThrow()

    ait "adds the plugin buttons to the available buttons", required, (Toolbar) ->
      toolbar = new Toolbar()
      toolbar.availableButtons = {}
      toolbar.addPlugin(plugin)
      expect(toolbar.availableButtons["TestButton"]).toBeDefined()

    ait "appends the plugin's default toolbar if no button groups were given", required, (Toolbar) ->
      toolbar = new Toolbar()
      toolbar.availableButtons = {}
      toolbar.addPlugin(plugin)
      expect(toolbar.buttons.length).toEqual(1)
      expect(toolbar.buttons[0]).toEqual("TestButton")

  describe "#addAction", ->
    ait "adds the action and binds to the plugin", required, (Toolbar) ->
      testValue = false
      plugin.testFn = null
      plugin.testValue = true
      spyOn(plugin, "testFn").andCallFake(-> testValue = this.testValue)
      toolbar = new Toolbar()
      toolbar.api = api
      toolbar.addAction(plugin, "testEvent", plugin.testFn)
      toolbar.api.trigger("testEvent.#{toolbar.namespace}")
      expect(plugin.testFn).toHaveBeenCalled()
      expect(testValue).toBeTruthy()

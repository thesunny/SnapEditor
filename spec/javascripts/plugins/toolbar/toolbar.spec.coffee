require ["cs!plugins/toolbar/toolbar"], (Toolbar) ->
  describe "Toolbar", ->
    $templates = null
    $.ajax(url: "spec/javascripts/fixtures/templates.html", async: false, success: (html) -> $templates = $("<div/>").html(html))

    toolbar = plugin = null
    beforeEach ->
      toolbar = new Toolbar($templates)
      plugin =
        register: (api) ->,
        getDefaultToolbar: -> "TestButton"
        getToolbar: -> TestButton: "html"

    describe "#addPlugin", ->
      it "throws an error if there is no #getDefaultToolbar()", ->
        plugin.getDefaultToolbar = null
        expect(-> toolbar.addPlugin(plugin)).toThrow()

      it "adds the plugin buttons to the available buttons", ->
        toolbar.availableButtons = {}
        toolbar.addPlugin(plugin)
        expect(toolbar.availableButtons["TestButton"]).toBeDefined()

      it "does not append the plugin's default toolbar if a default plugin is given", ->
        toolbar.availableButtons = {}
        toolbar.addPlugin(plugin, true)
        expect(toolbar.buttons.length).toEqual(0)

      it "does not append the plugin's default toolbar if buttons were given", ->
        toolbar = new Toolbar($templates, [], [], [], ["TestButton"])
        toolbar.availableButtons = {}
        toolbar.addPlugin(plugin, false)
        expect(toolbar.buttons.length).toEqual(1)

      it "appends the plugin's default toolbar if a custom plugin is given and no buttons were given", ->
        toolbar.availableButtons = {}
        toolbar.addPlugin(plugin, false)
        expect(toolbar.buttons.length).toEqual(1)
        expect(toolbar.buttons[0]).toEqual("TestButton")

    describe "#addAction", ->
      it "adds the action and binds to the plugin", ->
        testValue = false
        plugin.testFn = null
        plugin.testValue = true
        spyOn(plugin, "testFn").andCallFake(-> testValue = this.testValue)
        toolbar.api = $("<div/>")
        toolbar.addAction(plugin, "testEvent", plugin.testFn)
        toolbar.api.trigger("testEvent.#{toolbar.namespace}")
        expect(plugin.testFn).toHaveBeenCalled()
        expect(testValue).toBeTruthy()

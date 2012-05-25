require ["jquery.custom", "core/plugins"], ($, Plugins) ->
  describe "Plugins", ->
    $templates = null
    $.ajax(url: "spec/javascripts/support/assets/templates/snapeditor.html", async: false, success: (html) -> $templates = $("<div/>").html(html))

    plugins = plugin = null
    beforeEach ->
      plugins = new Plugins($("<div/>"), $templates)
      plugin =
        register: (api) ->,
        getUI: (ui) ->
          return {
            "toolbar:default": "TestButton"
            TestButton: ui.button(action: "test", description: "testing")
          }

    describe "#addUIs", ->
      beforeEach ->
        plugins.toolbarComponents = config: [], available: {}

      describe "toolbar default", ->
        beforeEach ->
          plugin =
            register: (api) ->,
            getUI: (ui) ->
              return {
                TestButton: ui.button(action: "test", description: "testing")
              }

        it "throws an error if no toolbar default is given and the plugin is not a default and there is no custom toolbar components", ->
          expect(-> plugins.addUIs(plugin, false)).toThrow()

        it "does not throw an error if no toolbar default is given and the plugin is a default", ->
          expect(-> plugins.addUIs(plugin, true)).not.toThrow()

        it "does not throw an error if no toolbar default is given and custom toolbar components are given", ->
          plugins = new Plugins($("<div/>"), $templates, [], [], [], [])
          plugins.toolbarComponents = config: [], available: {}
          expect(-> plugins.addUIs(plugin, false)).not.toThrow()


    describe "#addUI", ->
      describe "when a toolbar component is given", ->
        beforeEach ->
          plugins.toolbarComponents = config: [], available: {}

        it "adds the component to the list of available toolbar components", ->
          plugins.addUI("test", "component")
          expect(plugins.toolbarComponents.config.length).toEqual(0)
          expect(plugins.toolbarComponents.available.test).toEqual(["component"])

        it "adds the default component to the toolbar config", ->
          plugins.addUI("test", "component", "default")
          expect(plugins.toolbarComponents.config.length).toEqual(1)
          expect(plugins.toolbarComponents.available.test).toEqual(["component"])

        it "adds the default components to the toolbar config", ->
          plugins.addUI("test", "component", ["default", "another"])
          expect(plugins.toolbarComponents.config.length).toEqual(2)
          expect(plugins.toolbarComponents.available.test).toEqual(["component"])

      describe "when a contextmenu component is given", ->
        beforeEach ->
          plugins.contextMenuButtons = {}

        it "adds the component given the key does not exist", ->
          plugins.addUI("context:table", "component")
          expect(plugins.contextMenuButtons.table).toEqual(["component"])

        it "appends the component given the key exists", ->
          plugins.contextMenuButtons.table = ["something"]
          plugins.addUI("context:table", "component")
          expect(plugins.contextMenuButtons.table).toEqual(["something", "component"])

    describe "#addAction", ->
      it "adds the action and binds to the plugin", ->
        testValue = false
        plugin.testFn = null
        plugin.testValue = true
        spyOn(plugin, "testFn").andCallFake(-> testValue = this.testValue)
        plugins.api = $("<div/>")
        plugins.addAction(plugin, "testEvent", plugin.testFn)
        plugins.api.trigger("testEvent")
        expect(plugin.testFn).toHaveBeenCalled()
        expect(testValue).toBeTruthy()

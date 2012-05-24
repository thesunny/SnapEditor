require ["jquery.custom", "core/ui/ui.button"], ($, Button) ->
  describe "UI.Button", ->
    $templates = null
    $.ajax(url: "spec/javascripts/support/fixtures/templates.html", async: false, success: (html) -> $templates = $("<div/>").html(html))
    $tbButtonTemplate = $templates.find("snapeditor_toolbar_button_template")
    $cmButtonTemplate = $templates.find("snapeditor_contextmenu_button_template")

    templates = button = null
    beforeEach ->
      templates =
        toolbar: $tbButtonTemplate
        contextmenu: $cmButtonTemplate
      button = new Button(templates, action: "test", description: "testing")

    describe "#checkOptions", ->
      it "throws an error when no options are given", ->
        expect(-> new Button(templates)).toThrow()

      it "throws an error when no action is given", ->
        expect(-> new Button(templates, description: "testing")).toThrow()

      it "throws an error when no description is given", ->
        expect(-> new Button(templates, action: "test")).toThrow()

      it "throws an error when the icon is not an object", ->
        expect(-> new Button(templates, action: "test", icon: "image.png")).toThrow()

      it "throws an error when no url is given in the icon object", ->
        expect(-> new Button(templates, action: "test", description: "testing", icon: { width: 100, height: 100 })).toThrow()

      it "throws an error when no width is given in the icon object", ->
        expect(-> new Button(templates, action: "test", description: "testing", icon: { url: "image.png", height: 100 })).toThrow()

      it "throws an error when no height is given in the icon object", ->
        expect(-> new Button(templates, action: "test", description: "testing", icon: { url: "image.png", width: 100 })).toThrow()

      it "does not throw when everything is okay", ->
        new Button(templates, action: "test", description: "testing", icon: { url: "image.png", width: 100, height: 100 })

    describe "#normalizeIcon", ->
      it "does nothing if the icon is not set", ->
        button = new Button(templates, action: "test", description: "testing")
        expect(button.options.icon).toBeUndefined()

      it "sets the offset when it's not set", ->
        button = new Button(templates, action: "test", description: "testing", icon: { url: "image.png", width: 100, height: 100 })
        expect(button.options.icon.offset).toEqual([0, 0])

      it "normalizes the width to a string", ->
        button = new Button(templates, action: "test", description: "testing", icon: { url: "image.png", width: "2em", height: 100 })
        expect(button.options.icon.width).toEqual("2em")

        button = new Button(templates, action: "test", description: "testing", icon: { url: "image.png", width: 100, height: 100 })
        expect(button.options.icon.width).toEqual("100px")

      it "normalizes the height to a string", ->
        button = new Button(templates, action: "test", description: "testing", icon: { url: "image.png", width: 100, height: "2em" })
        expect(button.options.icon.height).toEqual("2em")

        button = new Button(templates, action: "test", description: "testing", icon: { url: "image.png", width: 100, height: 100 })
        expect(button.options.icon.height).toEqual("100px")

    describe "#generateClass", ->
      it "strips out any non-alphnumeric characters", ->
        expect(button.generateClass("test", "so*me.th-ing\tto te$st")).toEqual("snapeditor_test_somethingtotest")

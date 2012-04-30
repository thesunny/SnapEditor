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
      button = new Button(templates, action: "test", title: "testing", icon: "image.png")

    describe "#checkOptions", ->
      it "throws an error when no options are given", ->
        expect(-> new Button(templates)).toThrow()

      it "throws an error when no action is given", ->
        expect(-> new Button(templates, title: "testing", icon: "image.png")).toThrow()

      it "throws an error when no title is given", ->
        expect(-> new Button(templates, action: "test", icon: "image.png")).toThrow()

      it "throws an error when no icon is given", ->
        expect(-> new Button(templates, action: "test", title: "testing")).toThrow()

      it "throws an error when no url is given in the icon object", ->
        expect(-> new Button(templates, action: "test", title: "testing", icon: { offset: [0, 0] })).toThrow()

      it "throws an error when no offset is given in the icon object", ->
        expect(-> new Button(templates, action: "test", title: "testing", icon: { url: "image.png" })).toThrow()

      it "does not throw when everything is okay", ->
        new Button(templates, action: "test", title: "testing", icon: "image.png")
        new Button(templates, action: "test", title: "testing", icon: { url: "image.png", offset: [0, 0] })

    describe "#normalizeIcon", ->
      it "returns an object given a string", ->
        icon = button.normalizeIcon("image.png")
        expect(icon.url).toEqual("image.png")
        expect(icon.offset[0]).toEqual(0)
        expect(icon.offset[1]).toEqual(0)

      it "returns the object given an object", ->
        icon = button.normalizeIcon(url: "image.png", offset: [0, 0])
        expect(icon.url).toEqual("image.png")
        expect(icon.offset[0]).toEqual(0)
        expect(icon.offset[1]).toEqual(0)

    describe "#generateClass", ->
      it "strips out any non-alphnumeric characters", ->
        expect(button.generateClass("test", "so*me.th-ing\tto te$st")).toEqual("snapeditor_test_somethingtotest")

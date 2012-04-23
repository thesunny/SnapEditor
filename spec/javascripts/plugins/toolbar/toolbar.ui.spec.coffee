require ["plugins/toolbar/toolbar.ui"], (UI) ->
  describe "Toolbar.UI", ->
    $templates = null
    $.ajax(url: "spec/javascripts/fixtures/templates.html", async: false, success: (html) -> $templates = $("<div/>").html(html))

    ui = null
    beforeEach ->
      ui = new UI($templates)

    describe "#constructor", ->
      it "sets up all the templates", ->
        expect(ui.$buttonTemplate).not.toBeNull()
        #expect(ui.$selectTemplate).not.toBeNull()

    describe "#button", ->
      it "throws an error if no action is given", ->
        expect(-> ui.button()).toThrow()

      it "generates a button with the given action", ->
        fn = ui.button(action: "action")
        $button = $(fn())
        expect($button.attr("data-action")).toEqual("action")

      it "adds the given htmlOptions as attributes", ->
        fn = ui.button(
          action: "action"
          attrs:
            class: "class"
            value: "value"
        )
        $button = $(fn())
        expect($button.attr("class")).toEqual("class")
        expect($button.attr("value")).toEqual("value")

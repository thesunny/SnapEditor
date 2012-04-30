require ["core/toolbar/toolbar.builder"], (Builder) ->
  describe "Toolbar.Builder", ->
    availableComponents = null
    beforeEach ->
      component =
        htmlForToolbar: -> "html"
      availableComponents =
        combo: ["component", component]
        component: [component]
        components: [component, component, component]

    describe "#build", ->
      it "builds the toolbar", ->
        $templates = null
        $.ajax(url: "spec/javascripts/support/fixtures/templates.html", async: false, success: (html) -> $templates = $("<div/>").html(html))
        builder = new Builder(
          $templates.find("#snapeditor_toolbar_template")[0],
          availableComponents,
          ["component", "components", "|", "combo"]
        )
        $div = builder.build()
        expect($div.hasClass("toolbar")).toBeTruthy()
        expect($div.find(".group").length).toEqual(2)

        $group = $($div.find(".group")[0])
        # IE returns uppercased HTML tags, extra whitespaces and missing ""
        # around attributes. This basically normalizes it across all browsers.
        expect($group.html().replace(/[\s"]*/g, "")).toEqual('htmlhtmlhtmlhtml')

        $group = $($div.find(".group")[1])
        expect($group.html().replace(/\s*/g, "")).toEqual("htmlhtml")

    describe "#getComponents", ->
      it "returns an object containing all the components", ->
        builder = new Builder(null, availableComponents, ["component", "component", "|", "components", "|", "combo"])
        components = builder.getComponents()
        expect(components.length).toEqual(3)
        expect(components[0].html).toEqual("htmlhtml")
        expect(components[1].html).toEqual("htmlhtmlhtml")
        expect(components[2].html).toEqual("htmlhtml")

    describe "#getComponentHtml", ->
      builder = null
      beforeEach ->
        builder = new Builder(null, availableComponents, null)

      it "throws an error when the component is not available", ->
        builder.availableComponents = {}
        expect(-> builder.getComponentHtml("component")).toThrow()

      it "renders a single component", ->
        expect(builder.getComponentHtml("component")).toEqual("html")

      it "renders multiple components", ->
        expect(builder.getComponentHtml("components")).toEqual("htmlhtmlhtml")

      it "renders a combination of components", ->
        expect(builder.getComponentHtml("combo")).toEqual("htmlhtml")

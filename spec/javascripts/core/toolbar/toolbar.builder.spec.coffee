require ["core/toolbar/toolbar.builder"], (Builder) ->
  describe "Toolbar.Builder", ->
    availableComponents = null
    beforeEach ->
      component =
        htmlForToolbar: -> "html"
        cssForToolbar: -> "css"
      availableComponents =
        combo: ["component", component]
        component: [component]
        components: [component, component, component]

    describe "#build", ->
      it "builds the toolbar", ->
        $templates = null
        $.ajax(url: "spec/javascripts/support/assets/templates/snapeditor.html", async: false, success: (html) -> $templates = $("<div/>").html(html))
        builder = new Builder(
          {},
          $templates.find("#snapeditor_toolbar_template")[0],
          availableComponents,
          ["component", "components", "|", "combo"]
        )
        [$div, css] = builder.build()
        expect($div.hasClass("toolbar")).toBeTruthy()
        expect($div.find(".group").length).toEqual(2)

        $group = $($div.find(".group")[0])
        expect(clean($group.html()).replace(/[\s]*/g, "")).toEqual('htmlhtmlhtmlhtml')

        $group = $($div.find(".group")[1])
        expect($group.html().replace(/\s*/g, "")).toEqual("htmlhtml")

        expect(css).toEqual("csscsscsscsscsscss")

    describe "#getComponents", ->
      it "returns an object containing all the components", ->
        builder = new Builder({}, null, availableComponents, ["component", "component", "|", "components", "|", "combo"])
        [components, css] = builder.getComponents()
        expect(components.length).toEqual(3)
        expect(components[0].html).toEqual("htmlhtml")
        expect(components[1].html).toEqual("htmlhtmlhtml")
        expect(components[2].html).toEqual("htmlhtml")
        expect(css).toEqual("csscsscsscsscsscsscss")

      it "flags the last component", ->
        builder = new Builder({}, null, availableComponents, ["component", "component", "|", "components", "|", "combo"])
        [components, css] = builder.getComponents()
        expect(components[2].last).toBeTruthy()

    describe "#getComponentHtmlAndCss", ->
      builder = null
      beforeEach ->
        builder = new Builder({}, null, availableComponents, null)

      it "throws an error when the component is not available", ->
        builder.availableComponents = {}
        expect(-> builder.getComponentHtmlAndCss("component")).toThrow()

      it "renders a single component", ->
        expect(builder.getComponentHtmlAndCss("component")).toEqual(["html", "css"])

      it "renders multiple components", ->
        expect(builder.getComponentHtmlAndCss("components")).toEqual(["htmlhtmlhtml", "csscsscss"])

      it "renders a combination of components", ->
        expect(builder.getComponentHtmlAndCss("combo")).toEqual(["htmlhtml", "csscss"])

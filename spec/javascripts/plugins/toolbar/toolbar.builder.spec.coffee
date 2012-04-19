require ["cs!plugins/toolbar/toolbar.builder"], (Builder) ->
  describe "Toolbar.Builder", ->
    availableButtons = null
    beforeEach ->
      availableButtons =
        buttonHtml: -> "html"
        buttons: -> [(-> "html1"), (-> "html2")]

    describe "#build", ->
      it "builds the toolbar", ->
        $templates = null
        $.ajax(url: "spec/javascripts/fixtures/templates.html", async: false, success: (html) -> $templates = $("<div/>").html(html))
        builder = new Builder(
          $templates,
          availableButtons,
          ["buttonHtml", "-", "buttons", "|", "buttonHtml"]
        )
        $div = builder.build()
        expect($div.hasClass("toolbar")).toBeTruthy()
        expect($div.find(".group").length).toEqual(2)

        $group = $($div.find(".group")[0])
        # IE returns uppercased HTML tags, extra whitespaces and missing ""
        # around attributes. This basically normalizes it across all browsers.
        expect($group.html().toLowerCase().replace(/[\s"]*/g, "")).toEqual('html<spanclass=gap></span>html1html2')

        $group = $($div.find(".group")[1])
        expect($group.html().replace(/\s*/g, "")).toEqual("html")

    describe "#getButtonHtml", ->
      builder = null
      beforeEach ->
        builder = new Builder()

      it "throws an error when the button is not available", ->
        builder.availableButtons = {}
        expect(-> builder.getButtonHtml("button")).toThrow()

      it "renders the given button", ->
        builder.availableButtons = availableButtons
        expect(builder.getButtonHtml("buttonHtml")).toEqual("html")

    describe "#renderButton", ->
      builder = null
      beforeEach ->
        builder = new Builder()

      it "throws an error if the renderer returns an unrecognized format", ->
        expect(-> builder.renderButton("button", -> {})).toThrow()

      it "returns the string if the renderer returns a string", ->
        expect(builder.renderButton("button", -> "html")).toEqual("html")

      it "returns a concatentated string if an array of renderers is given", ->
        expect(builder.renderButton("button", -> ["1",(-> "2"),(-> "3")])).toEqual("123")

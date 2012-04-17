describe "Toolbar.Builder", ->
  required = ["cs!plugins/toolbar/toolbar.builder"]

  availableButtons = null
  beforeEach ->
    availableButtons =
      buttonHtml: -> "<button>button</button>"
      buttonObject: -> {title: "object", event: "object"}
      buttonObjects: -> [{title: "b1", event: "button1"}, {title: "b2", event: "button2"}]

  describe "#build", ->
    ait "builds the toolbar", required, (Builder) ->
      templates = null
      $.ajax(url: "spec/javascripts/fixtures/templates.html", async: false, success: (html) -> templates = $("<div/>").html(html))
      builder = new Builder(
        templates,
        availableButtons,
        ["buttonObjects", "-", "buttonHtml", "|", "buttonHtml"]
      )
      $div = builder.build()
      expect($div.hasClass("toolbar")).toBeTruthy()
      expect($div.find(".group").length).toEqual(2)

      $group = $($div.find(".group")[0])
      expect($group.children().length).toEqual(4)
      expect($($group.children()[0]).attr("data-event")).toEqual("button1")
      expect($($group.children()[1]).attr("data-event")).toEqual("button2")
      expect($($group.children()[2]).hasClass("gap")).toBeTruthy()
      expect($($group.children()[3]).tagName()).toEqual("button")

      $group = $($div.find(".group")[1])
      expect($group.children().length).toEqual(1)
      expect($($group.children()[0]).tagName()).toEqual("button")

  describe "#getButtonHtml", ->
    ait "throws an error when the button is not available", required, (Builder) ->
      builder = new Builder()
      builder.availableButtons = {}
      expect(-> builder.getButtonHtml("button")).toThrow()

    ait "throws an error when the toolbar format is incorrect", required, (Builder) ->
      builder = new Builder()
      builder.availableButtons = button: -> {}
      expect(-> builder.getButtonHtml("button")).toThrow()

    ait "returns the html string if the output is a string", required, (Builder) ->
      builder = new Builder()
      builder.availableButtons = availableButtons
      expect(builder.getButtonHtml("buttonHtml")).toEqual("<button>button</button>")

    ait "builds the buttons if the output is an object", required, (Builder) ->
      builder = new Builder()
      builder.availableButtons = availableButtons
      spyOn(builder, "buildButtons").andReturn("html")
      expect(builder.getButtonHtml("buttonObject")).toEqual("html")

    ait "builds the buttons if the output is an array of objects", required, (Builder) ->
      builder = new Builder()
      builder.availableButtons = availableButtons
      spyOn(builder, "buildButtons").andReturn("html")
      expect(builder.getButtonHtml("buttonObjects")).toEqual("html")

  describe "#buildButtons", ->
    ait "throws an error if the button is missing a title property", required, (Builder) ->
      builder = new Builder()
      builder.buttonTemplate = $("<div/>")
      expect(-> builder.buildButtons([{event: 1}])).toThrow()

    ait "throws an error if the button is missing an event property", required, (Builder) ->
      builder = new Builder()
      builder.buttonTemplate = $("<div/>")
      expect(-> builder.buildButtons([{title: 1}])).toThrow()

    ait "returns html for the buttons", required, (Builder) ->
      builder = new Builder()
      builder.buttonTemplate = $("<div>{{title}}</div>")
      html = builder.buildButtons([{title: 1, event: 1}, {title: 2, event: 2}])
      expect(html).toEqual("12")

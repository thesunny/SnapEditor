require ["jquery.custom", "core/formizer/formizer"], ($, Formizer) ->
  describe "Formizer", ->
    $container = $el = $toolbar = formizer = null
    beforeEach ->
      $container = $("<div/>").appendTo("body")
      $el = $('<div style="width: 100px; height: 300px;">This is some content</div>').appendTo($container)
      $toolbar = $('<div id="toolbar" style="display: hidden; height: 50px;">Toolbar</div>').appendTo($container)
      formizer = new Formizer($el)

    afterEach ->
      $container.remove()

    describe "#constructor", ->
      it "creates a content element", ->
        expect(formizer.$content).not.toBeNull()

    describe "#formize", ->
      it "splits the el into the toolbar and content", ->
        formizer.formize($toolbar)
        expect($el.children().length).toEqual(2)
        expect($el.children()[0].id).toEqual("toolbar")
        expect($($el.children()[1]).hasClass("snapeditor_form_content")).toBeTruthy()

      it "shows the toolbar", ->
        formizer.formize($toolbar)
        expect($toolbar.css("display")).toEqual("block")

      it "adjusts the height correctly", ->
        formizer.formize($toolbar)

        size = $el.getSize()
        expect(size.x).toEqual(100)
        expect(size.y).toEqual(300)

        size = $toolbar.getSize()
        expect(size.x).toEqual(100)
        expect(size.y).toEqual(50)

        size = $(".snapeditor_form_content").getSize()
        expect(size.x).toEqual(100)
        expect(size.y).toEqual(250)

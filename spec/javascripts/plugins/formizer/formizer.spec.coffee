require ["jquery.custom", "plugins/formizer/formizer"], ($, Formizer) ->
  describe "Formizer", ->
    $container = $el = $toolbar = formizer = null
    beforeEach ->
      $container = $("<div/>").appendTo("body")
      $el = $('<div style="width: 100px; height: 300px;">This is some content</div>').appendTo($container)
      $toolbar = $('<div id="toolbar" style="display: hidden; height: 50px;">Toolbar</div>').appendTo($container)
      formizer = new Formizer($el, $toolbar)

    afterEach ->
      $container.remove()

    describe "#call", ->
      it "splits the el into the toolbar and content", ->
        formizer.call()
        expect($el.children().length).toEqual(2)
        expect($el.children()[0].id).toEqual("toolbar")
        expect($($el.children()[1]).hasClass("snapeditor-form-content")).toBeTruthy()

      it "shows the toolbar", ->
        formizer.call()
        expect($toolbar.css("display")).toEqual("block")

      it "adjusts the height correctly", ->
        formizer.call()

        size = $el.getSize()
        expect(size.x).toEqual(100)
        expect(size.y).toEqual(300)

        size = $toolbar.getSize()
        expect(size.x).toEqual(100)
        expect(size.y).toEqual(50)

        size = $(".snapeditor-form-content").getSize()
        expect(size.x).toEqual(100)
        expect(size.y).toEqual(250)

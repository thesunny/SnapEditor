require ["jquery.custom"], ($) ->
  describe "jquery", ->
    $editable = null
    beforeEach ->
      $editable = addEditableFixture()

    afterEach ->
      $editable.remove()

    describe "#tagName", ->
      it "returns the lowercased version of the tagname", ->
        $el = $('<div id="el"></div>').appendTo($editable)
        expect($el.tagName()).toEqual("div")

    describe "#getCoordinates", ->
      it "returns the correct coordinates", ->
        $el = $('<div id="el"></div>').appendTo($editable)
        $el.attr("style", "
          position: fixed;
          top: 50px;
          left: 60px;
          width: 200px;
          height: 100px;
        ")
        coords = $el.getCoordinates()
        expect(coords.top).toEqual(50)
        expect(coords.bottom).toEqual(150)
        expect(coords.left).toEqual(60)
        expect(coords.right).toEqual(260)
        expect(coords.width).toEqual(200)
        expect(coords.height).toEqual(100)

    describe "#getScroll", ->
      it "returns the 0 with no scrolling", ->
        scroll = $(window).getScroll()
        expect(scroll.x).toEqual(0)
        expect(scroll.y).toEqual(0)

      it "returns the correct scroll", ->
        $el = $('<div id="el"></div>').appendTo($editable)
        $el.attr("style", "width: 6000px; height: 9000px;")
        window.scrollTo(300, 500)
        scroll = $(window).getScroll()
        expect(scroll.x).toEqual(300)
        expect(scroll.y).toEqual(500)
        window.scrollTo(0, 0)

    describe "#contexts", ->
      it "returns the matched contexts and the matched elements", ->
        $div = $('<div class="top">some <b>bold and <i>italic</i></b> text with an <img src="spec/javascripts/support/images/stub.png"> in it</div>')
        contexts = [".top", ".top b", "i", "#editable"]
        matchedContexts = $div.find("i").contexts(contexts, $editable[0])
        expect(matchedContexts[".top"]).toEqual($div[0])
        expect(matchedContexts[".top b"]).toEqual($div.find("b")[0])
        expect(matchedContexts["i"]).toEqual($div.find("i")[0])
        expect(matchedContexts["#editable"]).toBeUndefined()


    describe ".mustache", ->
      it "renders the given template and view", ->
        template = "before {{value}} after"
        view = value: "test"
        expect($.mustache(template, view)).toEqual("before test after")

    describe "#mustache", ->
      it "renders the given view using the element's HTML", ->
        $template = $("<div>before {{value}} after</div>")
        view = value: "test"
        expect($template.mustache(view)).toEqual("before test after")

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

    describe "#merge", ->
      it "merges the other node in", ->
        $el = $("<div>this is <b>my</b> div</div>").appendTo($editable)
        $other = $("<h1><i>this</i> is my other h1</h1>").appendTo($editable)
        $el.merge($other)
        expect(clean($editable.html())).toEqual("<div>this is <b>my</b> div<i>this</i> is my other h1</div>")

      it "does nothing when the element is a table", ->
        $el = $("<table><tbody><tr><td>text</td></tr></tbody></table").appendTo($editable)
        $other = $("<h1><i>this</i> is my other h1</h1>").appendTo($editable)
        html = $editable.html()
        $el.merge($other)
        expect(clean($editable.html())).toEqual(html)

      it "does nothing when the other is a table", ->
        $el = $("<h1><i>this</i> is my other h1</h1>").appendTo($editable)
        $other = $("<table><tbody><tr><td>text</td></tr></tbody></table").appendTo($editable)
        html = $editable.html()
        $el.merge($other)
        expect(clean($editable.html())).toEqual(html)

      it "merges the last item with the other when the element is a list", ->
        $el = $("<ul><li>first</li><li>last</li></ul>").appendTo($editable)
        $other = $("<h1><i>this</i> is my other h1</h1>").appendTo($editable)
        $el.merge($other)
        expect(clean($editable.html())).toEqual("<ul><li>first</li><li>last<i>this</i> is my other h1</li></ul>")

      it "merges the first item into the element when other is a list", ->
        $el = $("<h1><i>this</i> is my other h1</h1>").appendTo($editable)
        $other = $("<ul><li>first</li><li>last</li></ul>").appendTo($editable)
        $el.merge($other)
        expect(clean($editable.html())).toEqual("<h1><i>this</i> is my other h1first</h1><ul><li>last</li></ul>")

      it "removes the list when other is a list and the resulting list has no items after the merge", ->
        $el = $("<h1><i>this</i> is my other h1</h1>").appendTo($editable)
        $other = $("<ul><li>first</li></ul>").appendTo($editable)
        $el.merge($other)
        expect(clean($editable.html())).toEqual("<h1><i>this</i> is my other h1first</h1>")

    describe "#split", ->
      it "splits on the child node", ->
        $el = $("<div>this is <span>in the</span> first <b>and</b> this is in the <i>second</i></div>").appendTo($editable)
        [$first, $second] = $el.split($el.find("b"))
        expect($editable.find("div").length).toEqual(2)
        expect(clean($first.html())).toEqual("this is <span>in the</span> first ")
        expect(clean($second.html())).toEqual("<b>and</b> this is in the <i>second</i>")

    describe "#replaceElementWith", ->
      it "replaces the element with the given element and retains all the children", ->
        $el = $("<div>this is <b>some</b> text <i>to be<span>preserved</span></i></div>").appendTo($editable)
        $el.replaceElementWith($("<p>"))
        expect(clean($editable.html())).toEqual("<p>this is <b>some</b> text <i>to be<span>preserved</span></i></p>")

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

# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
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
      it "returns 0 with no scrolling", ->
        scroll = $(window).getScroll()
        expect(scroll.x).toEqual(0)
        expect(scroll.y).toEqual(0)

      it "returns the correct scroll", ->
        # Scroll the body instead of inserting a really large div  because IE
        # craps out otherwise.
        $("body").css(width: 6000, height: 9000)
        window.scrollTo(300, 500)
        scroll = $(window).getScroll()
        expect(scroll.x).toEqual(300)
        expect(scroll.y).toEqual(500)
        window.scrollTo(0, 0)
        $("body").css(width: "auto", height: "auto")

    describe "#getPadding", ->
      $el = null
      beforeEach ->
        $el = $("<div/>").appendTo($editable)

      it "returns the correct paddings when no padding is specified", ->
        padding = $el.getPadding()
        expect(padding.top).toEqual(0)
        expect(padding.bottom).toEqual(0)
        expect(padding.left).toEqual(0)
        expect(padding.right).toEqual(0)

      it "returns the correct paddings when 1 number is specified", ->
        $el.css("padding", 10)
        padding = $el.getPadding()
        expect(padding.top).toEqual(10)
        expect(padding.bottom).toEqual(10)
        expect(padding.left).toEqual(10)
        expect(padding.right).toEqual(10)

      it "returns the correct paddings when 2 numbers are specified", ->
        $el.css("padding", "10px 5px")
        padding = $el.getPadding()
        expect(padding.top).toEqual(10)
        expect(padding.bottom).toEqual(10)
        expect(padding.left).toEqual(5)
        expect(padding.right).toEqual(5)

      it "returns the correct paddings when 3 numbers are specified", ->
        $el.css("padding", "10px 5px 12px")
        padding = $el.getPadding()
        expect(padding.top).toEqual(10)
        expect(padding.bottom).toEqual(12)
        expect(padding.left).toEqual(5)
        expect(padding.right).toEqual(5)

      it "returns the correct paddings when 4 numbers are specified", ->
        $el.css("padding", "10px 5px 12px 7px")
        padding = $el.getPadding()
        expect(padding.top).toEqual(10)
        expect(padding.bottom).toEqual(12)
        expect(padding.left).toEqual(7)
        expect(padding.right).toEqual(5)

      it "returns the correct paddings when only 1 padding is specified", ->
        $el.css("padding-left", "10px")
        padding = $el.getPadding()
        expect(padding.top).toEqual(0)
        expect(padding.bottom).toEqual(0)
        expect(padding.left).toEqual(10)
        expect(padding.right).toEqual(0)

    describe "#getSize", ->
      it "returns the correct size", ->
        $el = $('<div id="el"></div>').appendTo($editable)
        $el.attr("style", "
          width: 200px;
          height: 100px;
        ")
        size = $el.getSize()
        expect(size.x).toEqual(200)
        expect(size.y).toEqual(100)

      it "returns the correct size with padding", ->
        $el = $('<div id="el"></div>').appendTo($editable)
        $el.attr("style", "
          width: 200px;
          height: 100px;
          padding: 10px 20px 30px 40px;
        ")
        size = $el.getSize(true)
        expect(size.x).toEqual(260)
        expect(size.y).toEqual(140)

      it "returns the correct coordinates with border width", ->
        $el = $('<div id="el"></div>').appendTo($editable)
        $el.attr("style", "
          width: 200px;
          height: 100px;
          border: solid 1px pink;
        ")
        size = $el.getSize(false, true)
        expect(size.x).toEqual(202)
        expect(size.y).toEqual(102)

    describe "#getBorderWidth", ->
      $el = null
      beforeEach ->
        $el = $('<div style="border: 1px solid pink;"/>').appendTo($editable)

      it "returns the correct borderWidths when no borderWidth is specified", ->
        $el = $("<div/>").appendTo($editable)
        borderWidth = $el.getBorderWidth()
        expect(borderWidth.top).toEqual(0)
        expect(borderWidth.bottom).toEqual(0)
        expect(borderWidth.left).toEqual(0)
        expect(borderWidth.right).toEqual(0)

      it "returns the correct borderWidths when 1 number is specified", ->
        $el.css("border-width", 10)
        borderWidth = $el.getBorderWidth()
        expect(borderWidth.top).toEqual(10)
        expect(borderWidth.bottom).toEqual(10)
        expect(borderWidth.left).toEqual(10)
        expect(borderWidth.right).toEqual(10)

      it "returns the correct borderWidths when 2 numbers are specified", ->
        $el.css("border-width", "10px 5px")
        borderWidth = $el.getBorderWidth()
        expect(borderWidth.top).toEqual(10)
        expect(borderWidth.bottom).toEqual(10)
        expect(borderWidth.left).toEqual(5)
        expect(borderWidth.right).toEqual(5)

      it "returns the correct borderWidths when 3 numbers are specified", ->
        $el.css("border-width", "10px 5px 12px")
        borderWidth = $el.getBorderWidth()
        expect(borderWidth.top).toEqual(10)
        expect(borderWidth.bottom).toEqual(12)
        expect(borderWidth.left).toEqual(5)
        expect(borderWidth.right).toEqual(5)

      it "returns the correct borderWidths when 4 numbers are specified", ->
        $el.css("border-width", "10px 5px 12px 7px")
        borderWidth = $el.getBorderWidth()
        expect(borderWidth.top).toEqual(10)
        expect(borderWidth.bottom).toEqual(12)
        expect(borderWidth.left).toEqual(7)
        expect(borderWidth.right).toEqual(5)

      it "returns the correct borderWidths when only 1 borderWidth is specified", ->
        $el = $('<div style="border-left: 10px solid pink;"/>').appendTo($editable)
        borderWidth = $el.getBorderWidth()
        expect(borderWidth.top).toEqual(0)
        expect(borderWidth.bottom).toEqual(0)
        expect(borderWidth.left).toEqual(10)
        expect(borderWidth.right).toEqual(0)

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
        expect($editable.html()).toEqual(html)

      it "does nothing when the other is a table", ->
        $el = $("<h1><i>this</i> is my other h1</h1>").appendTo($editable)
        $other = $("<table><tbody><tr><td>text</td></tr></tbody></table").appendTo($editable)
        html = $editable.html()
        $el.merge($other)
        expect($editable.html()).toEqual(html)

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

      it "merges the two list items together", ->
        $ul = $("<ul><li>first</li><li>last</li></ul>").appendTo($editable)
        $el = $ul.find("li").first()
        $other = $ul.find("li").last()
        $el.merge($other)
        expect($ul.find("li").length).toEqual(1)
        expect($ul.find("li").html()).toEqual("firstlast")

    describe "#split", ->
      $el = null
      beforeEach ->
        $el = $("<div><span></span>this is <span>in the</span> first <b>and</b> this is in the <i>second</i></div>").appendTo($editable)

      it "splits on the child node", ->
        [$first, $second] = $el.split($el.find("b"))
        expect($editable.find("div").length).toEqual(2)
        expect(clean($first.html())).toEqual("<span></span>this is <span>in the</span> first ")
        expect(clean($second.html())).toEqual("<b>and</b> this is in the <i>second</i>")

    describe "#replaceElementWith", ->
      it "replaces the element with the given element and retains all the children", ->
        $el = $("<div>this is <b>some</b> text <i>to be<span>preserved</span></i></div>").appendTo($editable)
        $el.replaceElementWith($("<p>"))
        expect(clean($editable.html())).toEqual("<p>this is <b>some</b> text <i>to be<span>preserved</span></i></p>")

    describe "#contexts", ->
      it "returns the matched contexts and the matched elements", ->
        $div = $('<div class="top">some <b>bold and <i>italic</i></b> text with an <img src="spec/javascripts/support/assets/images/stub.png"> in it</div>')
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

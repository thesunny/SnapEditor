require ["jquery.custom", "plugins/cleaner/cleaner.normalizer", "core/range"], ($, Normalizer, Range) ->
  describe "Cleaner.Normalizer", ->
    $editable = normalizer = null
    beforeEach ->
      $editable = addEditableFixture()
      api = $("<div/>")
      api.el = $editable[0]
      normalizer = new Normalizer(api)

    afterEach ->
      $editable.remove()

    describe "#blockify", ->
      beforeEach ->
        normalizer.api.defaultBlock = null
        spyOn(normalizer.api, "defaultBlock").andReturn(tag: "p", classes: ["normal", "highlight"])

      it "does nothing when no inline nodes are given", ->
        $editable.html("<div>block</div>")
        $div = $editable.find("div")
        normalizer.blockify([], $div[0])
        expect($editable.html().toLowerCase()).toEqual("<div>block</div>")

      it "throws away the block if it contains only whitespace", ->
        $editable.html("    
            <div>block</div>")
        $div = $editable.find("div")
        normalizer.blockify([$editable[0].childNodes[0]], $div[0])
        expect($editable.html().toLowerCase()).toEqual("<div>block</div>")

      it "wraps the inline nodes in a block using the parent as a template", ->
        $editable.html('<div class="normal">this <i>is</i> some <b>random</b><div>block</div></div>')
        $div = $editable.find("div")
        children = $div[0].childNodes
        inlineNodes = [children[0], children[1], children[2], children[3]]
        normalizer.blockify(inlineNodes, $div.find("div")[0])
        expect($div.html()).toEqual('<div class="normal">this <i>is</i> some <b>random</b></div><div>block</div>')

      it "wraps the inline nodes in the default block if the parent is th editor", ->
        $editable.html("this <i>is</i> some <b>random</b><div>block</div>")
        $div = $editable.find("div")
        children = $editable[0].childNodes
        inlineNodes = [children[0], children[1], children[2], children[3]]
        normalizer.blockify(inlineNodes, $div[0])
        expect($editable.html()).toEqual('<p class="normal highlight">this <i>is</i> some <b>random</b></p><div>block</div>')

    describe "#checkWhitelist", ->
      beforeEach ->
        normalizer.api.allowed = null
        normalizer.api.replacement = null

      it "returns the textnode", ->
        text = document.createTextNode("test")
        node = normalizer.checkWhitelist(text)
        expect(node).toBe(text)

      it "returns the whitelisted element", ->
        spyOn(normalizer.api, "allowed").andReturn(true)
        $el = $("<p/>")
        node = normalizer.checkWhitelist($el[0])
        expect(node).toBe(node)

      it "replaces the node with the whitelisted element and returns the replacement", ->
        spyOn(normalizer.api, "allowed").andReturn(false)
        spyOn(normalizer.api, "replacement").andReturn(tag: "div", classes: ["normal", "highlighted"])
        $el = $("<p>this is <b>some</b> inline <i>text</i></p>").appendTo($editable)
        $node = $(normalizer.checkWhitelist($el[0]))
        expect($node.tagName()).toEqual("div")
        expect($node.hasClass("normal")).toBeTruthy()
        expect($node.hasClass("highlighted")).toBeTruthy()
        expect($node.html().toLowerCase()).toEqual("this is <b>some</b> inline <i>text</i>")

    describe "#normalize", ->
      beforeEach ->
        normalizer.api.defaultBlock = -> tag: "p", classes: []
        spyOn(normalizer, "checkWhitelist").andCallFake((node) -> node)

      it "blockifies all the children when they are all inline nodes", ->
        $editable.html("these are some <b>inline</b> nodes that <i>should</i> be wrapped")
        normalizer.normalize($editable[0].firstChild, $editable[0].lastChild)
        expect($editable.html().toLowerCase()).toEqual("<p>these are some <b>inline</b> nodes that <i>should</i> be wrapped</p>")

    describe "#normalizeNodes", ->
      beforeEach ->
        normalizer.api.defaultBlock = -> tag: "p", classes: []
        spyOn(normalizer, "checkWhitelist").andCallFake((node) -> node)

      it "does nothing when all the children are inline nodes", ->
        $div = $("<div>this is <b>some</b> text with <i>no</i> blocks</div>").appendTo($editable)
        expect(normalizer.normalizeNodes($div[0].firstChild, $div[0].lastChild)).toBeFalsy()
        expect($editable.html().toLowerCase()).toEqual("<div>this is <b>some</b> text with <i>no</i> blocks</div>")

      it "blockifies all inline nodes and flattens blocks", ->
        $div = $("<div>this is <b>some</b> text with another <p>block</p> in it</div>").appendTo($editable)
        expect(normalizer.normalizeNodes($div[0].firstChild, $div[0].lastChild)).toBeTruthy()
        expect($editable.html().toLowerCase()).toEqual("<div><div>this is <b>some</b> text with another </div><p>block</p><div> in it</div></div>")

      it "flattens recursively", ->
        $div = $("<div>this is <b>some</b> text with another <div>block <em>and</em> even <p>another one</p> inside that</div> in it plus <div>another just in case</div></div>").appendTo($editable)
        expect(normalizer.normalizeNodes($div[0].firstChild, $div[0].lastChild)).toBeTruthy()
        expect($editable.html().toLowerCase()).toEqual("<div><div>this is <b>some</b> text with another </div><div>block <em>and</em> even </div><p>another one</p><div> inside that</div><div> in it plus </div><div>another just in case</div></div>")

      it "checks the whitelist", ->
        normalizer.api.allowed = null
        normalizer.api.replacement = null
        spyOn(normalizer.api, "allowed").andReturn(false)
        spyOn(normalizer.api, "replacement").andReturn(tag: "p", classes: ["normal"])
        normalizer.checkWhitelist.andCallThrough()

        $div = $("<div>this is <b>some</b> text with another <p>block</p> in it</div>").appendTo($editable)
        expect(normalizer.normalizeNodes($div[0].firstChild, $div[0].lastChild)).toBeTruthy()
        expect($editable.html().toLowerCase()).toEqual('<div><div>this is <b>some</b> text with another </div><p class="normal">block</p><div> in it</div></div>')

      it "starts and stops normalizing at the right places", ->
        $div = $("<div>this is <b>some</b> text with another <p>block</p> in it</div>").appendTo($editable)
        expect(normalizer.normalizeNodes($div.find("b")[0], $div.find("p")[0])).toBeTruthy()
        expect($editable.html().toLowerCase()).toEqual("<div>this is <div><b>some</b> text with another </div><p>block</p> in it</div>")

    describe "#flattenBlock", ->
      it "replaces the parent with the children", ->
        $div = $("<div>this is <em>some</em> text <p>to replace</p> the parent</div>").appendTo($editable)
        normalizer.flattenBlock($div[0])
        expect($editable.html().toLowerCase()).toEqual("this is <em>some</em> text <p>to replace</p> the parent")


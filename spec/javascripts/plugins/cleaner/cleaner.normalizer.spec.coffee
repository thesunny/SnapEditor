# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "plugins/cleaner/cleaner.normalizer", "core/helpers"], ($, Normalizer, Helpers) ->
  describe "Cleaner.Normalizer", ->
    $editable = normalizer = null
    beforeEach ->
      $editable = addEditableFixture()
      api = $("<div/>")
      api.el = $editable[0]
      api.createElement = (name) -> document.createElement(name)
      normalizer = new Normalizer(api, [".ignore", ".ignore2"])

    afterEach ->
      $editable.remove()

    describe "#blockify", ->
      beforeEach ->
        normalizer.api.getDefaultBlock = null
        spyOn(normalizer.api, "getDefaultBlock").andReturn($('<p class="normal highlight"></p>')[0])

      it "does nothing when no inline nodes are given", ->
        $editable.html("<div>block</div>")
        $div = $editable.find("div")
        normalizer.blockify([], $div[0])
        expect(clean($editable.html())).toEqual("<div>block</div>")

      it "throws away the block if it contains only whitespace", ->
        $editable.html("    
            <div>block</div>")
        $div = $editable.find("div")
        normalizer.blockify([$editable[0].childNodes[0]], $div[0])
        expect(clean($editable.html())).toEqual("<div>block</div>")

      it "wraps the inline nodes in a block using the parent as a template", ->
        $editable.html('<div class="normal">this <i>is</i> some <b>random</b><div>block</div></div>')
        $div = $editable.find("div")
        children = $div[0].childNodes
        inlineNodes = [children[0], children[1], children[2], children[3]]
        normalizer.blockify(inlineNodes, $div.find("div")[0])
        expect(clean($div.html())).toEqual('<div class=normal>this <i>is</i> some <b>random</b></div><div>block</div>')

      it "wraps the inline nodes in the default block if the parent is the editor", ->
        $editable.html("this <i>is</i> some <b>random</b><div>block</div>")
        $div = $editable.find("div")
        children = $editable[0].childNodes
        inlineNodes = [children[0], children[1], children[2], children[3]]
        normalizer.blockify(inlineNodes, $div[0])
        expect(clean($editable.html())).toEqual('<p class=normal highlight>this <i>is</i> some <b>random</b></p><div>block</div>')

    describe "#checkWhitelist", ->
      beforeEach ->
        normalizer.api.isAllowed = null
        normalizer.api.getReplacement = null
        normalizer.blacklisted = -> false

      it "returns the textnode", ->
        spyOn(normalizer.api, "isAllowed").andReturn(true)
        text = document.createTextNode("test")
        node = normalizer.checkWhitelist(text)
        expect(node).toBe(text)

      it "returns the whitelisted element", ->
        spyOn(normalizer.api, "isAllowed").andReturn(true)
        $el = $("<p/>")
        node = normalizer.checkWhitelist($el[0])
        expect(node).toBe(node)

      it "returns null if the element is blacklisted", ->
        spyOn(normalizer.api, "isAllowed").andReturn(false)
        normalizer.blacklisted = -> true
        $el = $("<p/>")
        expect(normalizer.checkWhitelist($el[0])).toBeNull()

      it "replaces the element with the whitelisted element and returns the replacement", ->
        spyOn(normalizer.api, "isAllowed").andReturn(false)
        spyOn(normalizer.api, "getReplacement").andReturn($('<div class="highlighted normal"></div>')[0])
        $el = $("<p>this is <b>some</b> inline <i>text</i></p>").appendTo($editable)
        $node = $(normalizer.checkWhitelist($el[0]))
        expect($node.tagName()).toEqual("div")
        expect($node.hasClass("normal")).toBeTruthy()
        expect($node.hasClass("highlighted")).toBeTruthy()
        expect(clean($node.html())).toEqual("this is <b>some</b> inline <i>text</i>")

      it "returns null when no replacement can be found", ->
        spyOn(normalizer.api, "isAllowed").andReturn(false)
        spyOn(normalizer.api, "getReplacement").andReturn(null)
        $el = $("<span>this is <b>some</b> inline <i>text</i></span>").appendTo($editable)
        expect(normalizer.checkWhitelist($el[0])).toBeNull()

    describe "#blacklisted", ->
      it "returns false when the node is a textnode", ->
        text = document.createTextNode("test")
        expect(normalizer.blacklisted(text)).toBeFalsy()

      it "returns false when the element is not blacklisted", ->
        $el = $("<p/>")
        expect(normalizer.blacklisted($el[0])).toBeFalsy()

      it "returns true when the element is blacklisted", ->
        $br = $('<br class="Apple-interchange-newline"/>')
        expect(normalizer.blacklisted($br[0])).toBeTruthy()
        $span = $('<span class="Apple-style-span"/>')
        expect(normalizer.blacklisted($span[0])).toBeTruthy()
        $span = $('<span class="Apple-tab-span"/>')
        expect(normalizer.blacklisted($span[0])).toBeTruthy()

    describe "#normalize", ->
      $b = $i = null
      beforeEach ->
        normalizer.api.getDefaultBlock = -> $("<p/>")[0]
        spyOn(normalizer, "checkWhitelist").andCallFake((node) -> node)
        $editable.html("these are some <b>inline</b> nodes that <i>should</i> be wrapped")
        $b = $editable.find("b")
        $i = $editable.find("i")

      it "blockifies all the children when they are all inline nodes", ->
        normalizer.normalize($b[0], $i[0])
        expect(clean($editable.html())).toEqual("these are some <p><b>inline</b> nodes that <i>should</i></p> be wrapped")

      it "blockifies all the children when they are all inline nodes and the start and end nodes have been replaced", ->
        normalizer.checkWhitelist.andCallFake((node) -> if Helpers.isTextnode(node) then node else null)
        normalizer.normalize($b[0], $i[0])
        expect(clean($editable.html())).toEqual("these are some <p>inline nodes that should</p> be wrapped")

    describe "#normalizeNodes", ->
      beforeEach ->
        # Everything is whitelisted.
        spyOn(normalizer, "checkWhitelist").andCallFake((node) -> node)

      it "does nothing when all the children are inline nodes and are all whitelisted", ->
        $div = $("<div>this is <b>some</b> text with <i>no</i> blocks</div>").appendTo($editable)
        expect(normalizer.normalizeNodes($div[0].firstChild, $div[0].lastChild)).toBeFalsy()
        expect(clean($editable.html())).toEqual("<div>this is <b>some</b> text with <i>no</i> blocks</div>")

      it "blockifies all inline nodes and flattens blocks", ->
        $div = $("<div>this is <b>some</b> text with another <p>block</p> in it</div>").appendTo($editable)
        expect(normalizer.normalizeNodes($div[0].firstChild, $div[0].lastChild)).toBeTruthy()
        if hasW3CRanges
          expect(clean($editable.html())).toEqual("<div><div>this is <b>some</b> text with another </div><p>block</p><div> in it</div></div>")
        else
          # In IE7/8, the space disappears after a block. This should be okay.
          expect(clean($editable.html())).toEqual("<div><div>this is <b>some</b> text with another </div><p>block</p><div>in it</div></div>")

      it "flattens blocks recursively", ->
        $div = $("<div>this is <b>some</b> text with another <div>block <em>and</em> even <p>another one</p> inside that</div> in it plus <div>another just in case</div></div>").appendTo($editable)
        expect(normalizer.normalizeNodes($div[0].firstChild, $div[0].lastChild)).toBeTruthy()
        if hasW3CRanges
          expect(clean($editable.html())).toEqual("<div><div>this is <b>some</b> text with another </div><div>block <em>and</em> even </div><p>another one</p><div> inside that</div><div> in it plus </div><div>another just in case</div></div>")
        else
          # In IE7/8, the space disappears after a block. This should be okay.
          expect(clean($editable.html())).toEqual("<div><div>this is <b>some</b> text with another </div><div>block <em>and</em> even </div><p>another one</p><div>inside that</div><div>in it plus </div><div>another just in case</div></div>")

      it "checks the whitelist and uses the replacement", ->
        normalizer.api.isAllowed = (node) -> Helpers.isTextnode(node)
        normalizer.api.getReplacement = -> $('<p class="normal"/>')[0]
        normalizer.checkWhitelist.andCallThrough()

        $div = $("<div>this is some text with another <p>block</p> in it</div>").appendTo($editable)
        expect(normalizer.normalizeNodes($div[0].firstChild, $div[0].lastChild)).toBeTruthy()
        if hasW3CRanges
          expect(clean($editable.html())).toEqual('<div><div>this is some text with another </div><p class=normal>block</p><div> in it</div></div>')
        else
          # In IE7/8, the space disappears after a block. This should be okay.
          expect(clean($editable.html())).toEqual('<div><div>this is some text with another </div><p class=normal>block</p><div>in it</div></div>')

      it "replaces the non-whitelisted block with the default block when all children are inline", ->
        normalizer.api.isAllowed = (node) -> Helpers.isTextnode(node)
        normalizer.api.getReplacement = -> $("<p/>")[0]
        normalizer.checkWhitelist.andCallThrough()

        $div = $("<div><div>this is some inline text</div></div>").appendTo($editable)
        expect(normalizer.normalizeNodes($div[0].firstChild, $div[0].lastChild)).toBeTruthy()
        expect(clean($div.html())).toEqual("<p>this is some inline text</p>")

      it "properly handles non-whitelisted block with blocks inside", ->
        normalizer.api.isAllowed = (node) -> Helpers.isTextnode(node) or node.tagName == "P"
        normalizer.api.getReplacement = -> $("<p/>")[0]
        normalizer.checkWhitelist.andCallThrough()

        $div = $("<div><div>inline text <p>a block</p></div></div>").appendTo($editable)
        expect(normalizer.normalizeNodes($div[0].firstChild, $div[0].lastChild)).toBeTruthy()
        expect(clean($div.html())).toEqual("<p>inline text </p><p>a block</p>")

      it "flattens the non-whitelisted block when it has no children", ->
        normalizer.api.isAllowed = (node) -> Helpers.isTextnode(node)
        normalizer.api.getReplacement = -> null
        normalizer.checkWhitelist.andCallThrough()

        $div = $("<div><div></div></div>").appendTo($editable)
        expect(normalizer.normalizeNodes($div[0].firstChild, $div[0].lastChild)).toBeTruthy()
        expect(clean($div.html())).toEqual("")

      it "checks the whitelist and replaces the node with its children when there is no replacement", ->
        normalizer.api.isAllowed = (node) -> Helpers.isTextnode(node)
        normalizer.api.getReplacement = -> null
        normalizer.checkWhitelist.andCallThrough()

        $div = $("<div>this is <b>some <i>inline</i> text</b> with more text</div>").appendTo($editable)
        expect(normalizer.normalizeNodes($div[0].firstChild, $div[0].lastChild)).toBeFalsy()
        expect(clean($editable.html())).toEqual('<div>this is some inline text with more text</div>')

      it "starts and stops normalizing at the right places", ->
        $div = $("<div>this is <b>some</b> text with another <p>block</p> in it</div>").appendTo($editable)
        expect(normalizer.normalizeNodes($div.find("b")[0], $div.find("p")[0])).toBeTruthy()
        if hasW3CRanges
          expect(clean($editable.html())).toEqual("<div>this is <div><b>some</b> text with another </div><p>block</p> in it</div>")
        else
          # In IE7/8, the space disappears after a block. This should be okay.
          expect(clean($editable.html())).toEqual("<div>this is <div><b>some</b> text with another </div><p>block</p>in it</div>")

      it "does not touch classes that should be ignored", ->
        $div = $('<div>before text<div class="ignore"><div>this should be ignored</div></div>middle text<p class="ignore2">this should also be ignored</p>more text</div>').appendTo($editable)
        expect(normalizer.normalizeNodes($div[0].firstChild, $div[0].lastChild)).toBeTruthy()
        expect(clean($editable.html())).toEqual("<div><div>before text</div><div class=ignore><div>this should be ignored</div></div><div>middle text</div><p class=ignore2>this should also be ignored</p><div>more text</div></div>")

      it "still treats ignored inlines as inline", ->
        $div = $('<div>before text <span class="ignore">ignore me</span> after text<p>block</p></div>').appendTo($editable)
        expect(normalizer.normalizeNodes($div[0].firstChild, $div[0].lastChild)).toBeTruthy()
        expect(clean($editable.html())).toEqual("<div><div>before text <span class=ignore>ignore me</span> after text</div><p>block</p></div>")

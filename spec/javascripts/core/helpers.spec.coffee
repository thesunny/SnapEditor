# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "core/helpers", "core/iframe.snapeditor"], ($, Helpers, IFrame) ->
  describe "helpers", ->
    $editable = null
    beforeEach ->
      $editable = addEditableFixture()

    afterEach ->
      $editable.remove()

    describe "#isElement", ->
      it "returns true for an element", ->
        el = document.createElement("div")
        expect(Helpers.isElement(el)).toBeTruthy()
      it "returns false for a text node", ->
        text = document.createTextNode("This is text")
        expect(Helpers.isElement(text)).toBeFalsy()

    describe "#isTextnode", ->
      it "returns true for a text node", ->
        text = document.createTextNode("This is text")
        expect(Helpers.isTextnode(text)).toBeTruthy()
      it "returns false for an element", ->
        el = document.createElement("div")
        expect(Helpers.isTextnode(el)).toBeFalsy()

    describe "#isBlock", ->
      it "returns false if a textnode is given", ->
        text = document.createTextNode("test")
        $editable[0].appendChild(text)
        expect(Helpers.isBlock(text)).toBeFalsy()

      it "returns true when an hr is given", ->
        $hr = $("<hr/>").appendTo($editable)
        expect(Helpers.isBlock($hr[0])).toBeTruthy()

      it "returns true when an image is given", ->
        $img = $("<img/>").appendTo($editable)
        expect(Helpers.isBlock($img[0])).toBeTruthy()

      describe "when the block is in the DOM", ->
        it "returns true when a block element is given", ->
          expect(Helpers.isBlock($("<div/>").appendTo($editable)[0])).toBeTruthy()

        it "returns false when an inline element is given", ->
          expect(Helpers.isBlock($("<span/>").appendTo($editable)[0])).toBeFalsy()

      describe "when the block is not in the DOM", ->
        it "returns true when a block element is given", ->
          expect(Helpers.isBlock($("<div/>")[0], false)).toBeTruthy()

        it "returns false when an inline element is given", ->
          expect(Helpers.isBlock($("<span/>")[0], false)).toBeFalsy()

        it "does not modify the element", ->
          testValue = false
          $div = $('<div id="div" class="normal"/>')
          $div.on("test", -> testValue = true)
          Helpers.isBlock($div[0], false)
          expect($div.hasClass("normal")).toBeTruthy()
          $div.trigger("test")
          expect(testValue).toBeTruthy()
          expect($("#div").length).toEqual(0)

    describe "#isEmpty", ->
      $el = null
      beforeEach ->
        $el = $("<div/>")

      it "returns false if there is an image", ->
        $el.html("<img/>")
        expect(Helpers.isEmpty($el[0])).toBeFalsy()

      it "returns false when there is content", ->
        $el.html("<p>  \n</p>   \n\r\n#{Helpers.zeroWidthNoBreakSpace} <div>hello</div>   ")
        expect(Helpers.isEmpty($el[0])).toBeFalsy()

      it "returns true when there is only whitepsace", ->
        $el.html("<p>  \n</p>   \n\r\n#{Helpers.zeroWidthNoBreakSpace}   ")
        expect(Helpers.isEmpty($el[0])).toBeTruthy()

    describe "#nodesFrom", ->
      $div = null
      beforeEach ->
        $div = $("<div>hello <b>world</b> this is <p>some text<p> for testing</div>")

      it "returns an empty array when either the start or end node is null", ->
        expect(Helpers.nodesFrom(null, $div[0].lastChild).length).toEqual(0)
        expect(Helpers.nodesFrom($div[0].firstChild, null).length).toEqual(0)

      it "returns a single node when startNode equals endNode", ->
        nodes = Helpers.nodesFrom($div[0].firstChild, $div[0].firstChild)
        expect(nodes.length).toEqual(1)
        expect(nodes[0]).toBe($div[0].firstChild)

      it "returns all the nodes between and including startNode and endNode", ->
        nodes = Helpers.nodesFrom($div[0].childNodes[2], $div[0].childNodes[4])
        expect(nodes.length).toEqual(3)
        expect(nodes[0]).toBe($div[0].childNodes[2])
        expect(nodes[1]).toBe($div[0].childNodes[3])
        expect(nodes[2]).toBe($div[0].childNodes[4])

    describe "#getSibling", ->
      describe "previous", ->
        it "returns null when there are no siblings", ->
          $editable.html("<div><p><span>span</span>inside</p>after</div>")
          $span = $editable.find("span")
          expect(Helpers.getSibling("previous", $span[0], $editable[0])).toBeNull()

        it "returns the sibling when it finds one", ->
          $editable.html("<div>sibling<p><span>span</span>inside</p>after</div>")
          $span = $editable.find("span")
          sibling = Helpers.getSibling("previous", $span[0], $editable[0])
          expect(sibling).not.toBeNull()
          expect(sibling).toBe($editable[0].firstChild.firstChild)

      describe "next", ->
        it "returns null when there are no siblings", ->
          $editable.html("<div>before<p>inside<span>span</span></p></div>")
          $span = $editable.find("span")
          expect(Helpers.getSibling("next", $span[0], $editable[0])).toBeNull()

        it "returns the sibling when it finds one", ->
          $editable.html("<div>before<p>inside<span>span</span></p>after</div>")
          $span = $editable.find("span")
          sibling = Helpers.getSibling("next", $span[0], $editable[0])
          expect(sibling).not.toBeNull()
          expect(sibling).toBe($editable[0].firstChild.lastChild)

        it "returns null when the siblings don't match the checker", ->
          $editable.html("<div>before<p>inside<span>span</span></p>after</div>")
          $span = $editable.find("span")
          sibling = Helpers.getSibling("next", $span[0], $editable[0], (node) -> false)
          expect(sibling).toBeNull()

    describe "#getSiblingCell", ->
      $table = null
      beforeEach ->
        $table = $("
          <table>
            <tbody>
              <tr class='first'><th class='1'>h1</th><th class='2'>h2</th></tr>
              <tr class='middle'><td class='1'>1.1</td><td class='2'>1.2</td></tr>
              <tr class='last'><td class='1'>2.1</td><td td class='2'>2.2</td></tr>
            </tbody>
          </table>
        ").appendTo($editable)

      describe "next", ->
        it "returns the immediate sibling when there is one", ->
          sibling = Helpers.getSiblingCell($table.find(".1").first(), true)
          expect(sibling.innerHTML).toEqual("h2")

        it "returns the first cell in the next row when there is no immediate sibling", ->
          sibling = Helpers.getSiblingCell($table.find(".2").first(), true)
          expect(sibling.innerHTML).toEqual("1.1")

        it "returns null when there is no sibling", ->
          sibling = Helpers.getSiblingCell($table.find(".2").last(), true)
          expect(sibling).toBeNull()

      describe "previous", ->
        it "returns the immediate sibling when there is one", ->
          sibling = Helpers.getSiblingCell($table.find(".2").last(), false)
          expect(sibling.innerHTML).toEqual("2.1")

        it "returns the last cell in the previous row when there is no immediate sibling", ->
          sibling = Helpers.getSiblingCell($table.find(".1").last(), false)
          expect(sibling.innerHTML).toEqual("1.2")

        it "returns null when there is no sibling", ->
          sibling = Helpers.getSiblingCell($table.find(".1").first(), false)
          expect(sibling).toBeNull()

    describe "#getTopNode", ->
      beforeEach ->
        $editable.html("this <b>must</b> be a test<div>or <i>maybe</i> not</div>")

      it "looks up the parent chain and returns the textnode at the top", ->
        node = Helpers.getTopNode($editable[0].childNodes[0], $editable[0])
        expect(node).toBe($editable[0].childNodes[0])

      it "looks up the parent chain and returns the element at the top", ->
        node = Helpers.getTopNode($editable.find("i")[0], $editable[0])
        expect(node).toBe($editable.find("div")[0])

    describe "#getDocument", ->
      it "returns this document when the element is in this document", ->
        expect(Helpers.getDocument($editable[0])).toBe(document)

      it "returns the iframe's document when the element is in the iframe", ->
        iframe = new IFrame(
          contents: "<b>hello</b>"
          load: ->
            b = $(@el).find("b")
            expect(Helpers.getDocument(b[0])).toBe(@doc)
        )
        $(iframe).appendTo($editable)

    describe "#getWindow", ->
      it "returns this window when the element is in this document", ->
        # NOTE: In IE7/8, Jasmine toBe() craps out when checking window.
        if hasW3CRanges
          expect(Helpers.getWindow($editable[0])).toBe(window)
        else
          expect(Helpers.getWindow($editable[0])).toBeDefined()
          expect(Helpers.getWindow($editable[0])).not.toBeNull()

    describe "#getParentIFrame", ->
      it "returns the correct iframe", ->
        $iframe1 = $(new IFrame(contents: "<b>hello</b>")).attr("id", "iframe1")
        $iframe2 = $(new IFrame(
          contents: "<b>hello</b>"
          load: ->
            b = $(@el).find("b")
            expect($(Helpers.getParentIFrame(b[0])).attr("id")).toEqual("iframe2")
        )).attr("id", "iframe2")
        $($iframe1).appendTo($editable)
        $($iframe2).appendTo($editable)

      it "returns null when the element is not inside an iframe", ->
        $div = $("<div>").appendTo($editable)
        expect(Helpers.getParentIFrame($div[0])).toBeNull()

    describe "#replaceWithChildren", ->
      it "replaces the parent with the children", ->
        $div = $("<div>this is <em>some</em> text <p>to replace</p> the parent</div>").appendTo($editable)
        Helpers.replaceWithChildren($div[0])
        if hasW3CRanges
          expect(clean($editable.html())).toEqual("this is <em>some</em> text <p>to replace</p> the parent")
        else
          # In IE7/8, the space disappears after a block. This should be okay.
          expect(clean($editable.html())).toEqual("this is <em>some</em> text <p>to replace</p>the parent")

    describe "#insertStyles", ->
      it "inserts the styles into the head", ->
        Helpers.insertStyles("test {position: absolute}")
        $style = $("head").find("style").last()
        expect($style).not.toBeNull()
        expect($style.attr("type")).toEqual("text/css")
        expect(clean($style.html())).toEqual("test {position: absolute}")
        $style.remove()

    describe "transformCoordinatesRelativeToOuter", ->
      mouseCoords = x: 100, y: 200
      elCoords =
        top: 100
        bottom: 200
        left: 300
        right: 400

      $div = null
      beforeEach ->
        $div = $("<div/>").appendTo($editable)

      describe "mouseCoords", ->
        it "returns the translated coordinates when there is an iframe", ->
          spyOn(Helpers, "getDocument").andReturn("doc")
          spyOn($.fn, "getScroll").andReturn(x: 5, y: 10)
          spyOn($.fn, "getCoordinates").andReturn(
            top: 1
            bottom: 2
            left: 3
            right: 4
          )
          outerCoords = Helpers.transformCoordinatesRelativeToOuter(mouseCoords, $div[0])
          expect(outerCoords.x).toEqual(98)
          expect(outerCoords.y).toEqual(191)

      describe "elCoords", ->
        it "returns the translated coordinates when there is an iframe", ->
          spyOn(Helpers, "getDocument").andReturn("doc")
          spyOn($.fn, "getScroll").andReturn(x: 5, y: 10)
          spyOn($.fn, "getCoordinates").andReturn(
            top: 1
            bottom: 2
            left: 3
            right: 4
          )
          outerCoords = Helpers.transformCoordinatesRelativeToOuter(elCoords, $div[0])
          expect(outerCoords.top).toEqual(91)
          expect(outerCoords.bottom).toEqual(191)
          expect(outerCoords.left).toEqual(298)
          expect(outerCoords.right).toEqual(398)

    describe "#typeOf", ->
      it "returns boolean", ->
        expect(Helpers.typeOf(true)).toEqual("boolean")
        expect(Helpers.typeOf(false)).toEqual("boolean")
      it "returns number", ->
        expect(Helpers.typeOf(1)).toEqual("number")
        expect(Helpers.typeOf(-1)).toEqual("number")
        expect(Helpers.typeOf(0)).toEqual("number")
        expect(Helpers.typeOf(1.233)).toEqual("number")
      it "returns string", ->
        expect(Helpers.typeOf("")).toEqual("string")
        expect(Helpers.typeOf("test")).toEqual("string")
      it "returns function", ->
        expect(Helpers.typeOf(->)).toEqual("function")
        expect(Helpers.typeOf(Helpers.typeOf)).toEqual("function")
      it "returns array", ->
        expect(Helpers.typeOf([])).toEqual("array")
        expect(Helpers.typeOf([1, 2, 3])).toEqual("array")
      it "returns date", ->
        expect(Helpers.typeOf(new Date())).toEqual("date")
      it "returns regexp", ->
        expect(Helpers.typeOf(/a/)).toEqual("regexp")
      it "returns element", ->
        el = document.createElement("div")
        expect(Helpers.typeOf(el)).toEqual("element")
      it "returns textnode", ->
        el = document.createTextNode("This is text")
        expect(Helpers.typeOf(el)).toEqual("textnode")
      it "returns window", ->
        expect(Helpers.typeOf(window)).toEqual("window")
      it "returns object", ->
        expect(Helpers.typeOf({})).toEqual("object")

    describe "#extend", ->
      it "extends all the methods", ->
        Module = { moduleKey: "module value", moduleFn: -> "module" }
        class TestClass
          @classKey: "class value"
          @classFn: -> "class"
        expect(TestClass.classKey).toEqual("class value")
        expect(TestClass.classFn()).toEqual("class")
        expect(TestClass.moduleKey).toBeUndefined()
        expect(TestClass.moduleFn).toBeUndefined()
        Helpers.extend(TestClass, Module)
        expect(TestClass.classKey).toEqual("class value")
        expect(TestClass.classFn()).toEqual("class")
        expect(TestClass.moduleKey).toBeDefined()
        expect(TestClass.moduleFn).toBeDefined()
        expect(TestClass.moduleKey).toEqual("module value")
        expect(TestClass.moduleFn()).toEqual("module")

    describe "#include", ->
      it "includes all the methods", ->
        Module = { moduleKey: "module value", moduleFn: -> "module" }
        class TestClass
          classKey: "class value"
          classFn: -> "class"
        test = new TestClass()
        expect(test.classKey).toEqual("class value")
        expect(test.classFn()).toEqual("class")
        expect(test.moduleKey).toBeUndefined()
        expect(test.moduleFn).toBeUndefined()
        Helpers.include(TestClass, Module)
        test = new TestClass()
        expect(test.classKey).toEqual("class value")
        expect(test.classFn()).toEqual("class")
        expect(test.moduleKey).toBeDefined()
        expect(test.moduleFn).toBeDefined()
        expect(test.moduleKey).toEqual("module value")
        expect(test.moduleFn()).toEqual("module")

    describe "#delegate", ->
      it "throws an error if the function is defined", ->
        object = delFn1: ->
        expect(-> Helpers.delegate(object, "delObject", "delFn1")).toThrow()

      it "throws an error if the delegate does not exist", ->
        object = {}
        expect(-> Helpers.delegate(object, "doesNotExist", "delFn1")).toThrow()

      it "delegates the functions to the delegate object", ->
        delFn1Value = delFn2Value = false
        object =
          delObject:
            delFn1: -> delFn1Value = true
            delFn2: -> delFn2Value = true
        Helpers.delegate(object, "delObject", "delFn1", "delFn2")
        object.delFn1()
        expect(delFn1Value).toBeTruthy()
        object.delFn2()
        expect(delFn2Value).toBeTruthy()

      it "delegates the functions to the delegate function", ->
        delFn1Value = false
        object = delFn: -> delFn1: -> delFn1Value = true
        Helpers.delegate(object, "delFn()", "delFn1")
        object.delFn1()
        expect(delFn1Value).toBeTruthy()

      it "passes arguments through", ->
        arg1 = false
        arg2 = ""
        object = delObject: delFn: (a, b) -> arg1 = a and arg2 = b
        Helpers.delegate(object, "delObject", "delFn")
        object.delFn(true, "passed")
        expect(arg1).toBeTruthy()
        expect(arg2).toEqual("passed")

      it "binds the delegate function to the object", ->
        object =
          value: false
          delFn: ->
            @value = true
            return delFn1: ->
        Helpers.delegate(object, "delFn()", "delFn1")
        object.delFn1()
        expect(object.value).toBeTruthy()

      it "binds the delegated function to the delegate object", ->
        object =
          delObject:
            value: false
            delFn1: -> @value = true
        Helpers.delegate(object, "delObject", "delFn1")
        object.delFn1()
        expect(object.delObject.value).toBeTruthy()

    describe "#deepClone", ->
      it "clones an object", ->
        object = { a: 1, b: 2 }
        clone = Helpers.deepClone(object)
        expect(clone).not.toBe(object)
        expect(object.a).toEqual(1)
        expect(object.b).toEqual(2)

      it "clones an array", ->
        object = [1, 2, 3]
        clone = Helpers.deepClone(object)
        expect(clone).not.toBe(object)
        expect(clone.length).toEqual(3)
        expect(clone[0]).toEqual(1)
        expect(clone[1]).toEqual(2)
        expect(clone[2]).toEqual(3)

      it "doesn't clone a string", ->
        object = "string"
        clone = Helpers.deepClone(object)
        expect(clone).toBe(object)

      it "doesn't clone a number", ->
        object = 1
        clone = Helpers.deepClone(object)
        expect(clone).toBe(object)

      it "doesn't clone a function", ->
        object = ->
        clone = Helpers.deepClone(object)
        expect(clone).toBe(object)

      it "deep clones a mixed object", ->
        object =
          a: 1
          b: [1, 2]
          c:
            aa: 1
            bb: 2
        clone = Helpers.deepClone(object)
        expect(clone).not.toBe(object)
        expect(clone.a).toEqual(1)
        expect(clone.b).not.toBe(object.b)
        expect(clone.b.length).toEqual(2)
        expect(clone.b[0]).toEqual(1)
        expect(clone.b[1]).toEqual(2)
        expect(clone.c).not.toBe(object.c)
        expect(clone.c.aa).toEqual(1)
        expect(clone.c.bb).toEqual(2)

      it "deep clones a mixed array", ->
        object = [1, a: 1, b: 2]
        clone = Helpers.deepClone(object)
        expect(clone).not.toBe(object)
        expect(clone.length).toEqual(2)
        expect(clone[0]).toEqual(1)
        expect(clone[1]).not.toBe(object[1])
        expect(clone[1].a).toEqual(1)
        expect(clone[1].b).toEqual(2)

    describe "#pass", ->
      it "passes arguments through", ->
        sum = (one, two, three) -> one + two + three
        boundSum = Helpers.pass(sum, [1, 2, 3], this)
        expect(boundSum()).toEqual(6)
      it "binds properly", ->
        sum = (one, two) -> one + two + this.three
        obj = { three: 3 }
        boundSum = Helpers.pass(sum, [1, 2], obj)
        expect(boundSum()).toEqual(6)

    describe "#capitalize", ->
      it "capializes the first letter of each word", ->
        string = "this Is a test 1 1a = =a"
        expect(Helpers.capitalize(string)).toEqual("This Is A Test 1 1a = =A")

    describe "#displayShortcut", ->
      it "generates the proper display shortcut", ->
        expect(Helpers.displayShortcut("ctrl+shift+t")).toEqual("Ctrl+Shift+T")

    describe "#normalize", ->
      it "normalizes an email", ->
        expect(Helpers.normalizeURL("wesley@snapeditor.com")).toEqual("mailto:wesley@snapeditor.com")

      it "normalizes a full URL", ->
        expect(Helpers.normalizeURL("http://snapeditor.com")).toEqual("http://snapeditor.com")

      it "normalizes a URL without a protocol", ->
        expect(Helpers.normalizeURL("//snapeditor.com")).toEqual("http://snapeditor.com")

      it "normalizes an absolute path", ->
        expect(Helpers.normalizeURL("/abc")).toEqual("/abc")

      it "normalizes a relative path", ->
        expect(Helpers.normalizeURL("abc")).toEqual("http://abc")

      it "normalizes a domain", ->
        expect(Helpers.normalizeURL("snapeditor.com")).toEqual("http://snapeditor.com")

    describe "#uniqueArray", ->
      it "returns an unique array", ->
        expect(Helpers.uniqueArray(["a", "b", "c", "a", "a", "b", "d", "e", "c"])).toEqual(["a", "b", "c", "d", "e"])

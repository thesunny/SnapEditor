require ["jquery.custom", "core/whitelist/whitelist.object"], ($, WhitelistObject) ->
  describe "Whitelist.Object", ->
    describe "#constructor", ->
      it "sorts the classes alphabetically", ->
        obj = new WhitelistObject("p", null, ["normal", "highlighted"])
        expect(obj.classes).toEqual("highlighted normal")

    describe "#getElement", ->
      it "builds an element with the given tag and no classes and attributes", ->
        obj = new WhitelistObject("p", null, [], [])
        $el = $(obj.getElement(document, $("<div/>")[0]))
        expect($el.tagName()).toEqual("p")
        expect($el.attr("class")).toBeUndefined()

      it "builds an element with the given tag and classes and no attributes", ->
        obj = new WhitelistObject("p", null, ["normal", "highlighted"], [])
        $el = $(obj.getElement(document, $("<div/>")[0]))
        expect($el.tagName()).toEqual("p")
        expect($el.attr("class")).toEqual("highlighted normal")

      it "builds an element with the given tag and attributes and no classes", ->
        obj = new WhitelistObject("p", null, [], ["width"])
        $el = $(obj.getElement(document, $('<div width="100px" height="200px"/>')[0]))
        expect($el.tagName()).toEqual("p")
        expect($el.attr("width")).toEqual("100px")
        expect($el.attr("height")).toBeUndefined()

    describe "#idMatches", ->
      it "returns true when both the element and object don't have ids", ->
        obj = new WhitelistObject("p")
        expect(obj.idMatches($("<p/>")[0])).toBeTruthy()

      it "returns true when both the element and object have the same ids", ->
        obj = new WhitelistObject("p", "special")
        expect(obj.idMatches($('<p id="special"/>')[0])).toBeTruthy()

      it "returns false when the element and object have different ids", ->
        obj = new WhitelistObject("p", "special")
        expect(obj.idMatches($('<p id="notspecial"/>')[0])).toBeFalsy()

      it "returns false when the element has an id and the object does not", ->
        obj = new WhitelistObject("p")
        expect(obj.idMatches($('<p id="special"/>')[0])).toBeFalsy()

      it "returns false when the element does not have an id and the object does", ->
        obj = new WhitelistObject("p", "special")
        expect(obj.idMatches($("<p/>")[0])).toBeFalsy()

    describe "#classesMatch", ->
      it "returns true when both the element and object don't have classes", ->
        obj = new WhitelistObject("p", null, [])
        expect(obj.classesMatch($("<p/>")[0])).toBeTruthy()

      it "returns true when both the element and object have classes", ->
        obj = new WhitelistObject("p", null, ["normal", "highlighted", "large"])
        expect(obj.classesMatch($('<p class="normal large highlighted"/>')[0])).toBeTruthy()

      it "returns false when the element and object have different classes", ->
        obj = new WhitelistObject("p", null, ["normal", "large"])
        expect(obj.classesMatch($('<p class="normal large highlighted"/>')[0])).toBeFalsy()

      it "returns false when the element has classes and the object does not", ->
        obj = new WhitelistObject("p", null, [])
        expect(obj.classesMatch($('<p class="normal large highlighted"/>')[0])).toBeFalsy()

      it "returns false when the element does not have classes and the object does", ->
        obj = new WhitelistObject("p", null, ["normal", "highlighted", "large"])
        expect(obj.classesMatch($("<p/>")[0])).toBeFalsy()

    describe "#attributesAllowed", ->
      obj = null
      beforeEach ->
        obj = new WhitelistObject("p", null, [], ["width", "height"])

      it "returns true when the element has no attributes", ->
        expect(obj.attributesAllowed($("<p/>")[0])).toBeTruthy()

      it "returns true when the element contains id and class", ->
        expect(obj.attributesAllowed($('<p id="special" class="normal highlighted"/>')[0])).toBeTruthy()

      it "returns true when the element contains only allowed attributes", ->
        expect(obj.attributesAllowed($('<p width="100px" height="100px"/>')[0])).toBeTruthy()

      it "returns false when the element contains disallowed attributes", ->
        expect(obj.attributesAllowed($('<p width="100px" src="some/url"/>')[0])).toBeFalsy()

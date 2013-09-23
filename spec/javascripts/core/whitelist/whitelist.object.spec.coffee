# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "core/whitelist/whitelist.object"], ($, WhitelistObject) ->
  describe "Whitelist.Object", ->
    describe "#constructor", ->
      it "sorts the classes alphabetically", ->
        obj = new WhitelistObject("p", null, ["normal", "highlighted"])
        expect(obj.classes).toEqual("highlighted normal")

    describe "#addClasses", ->
      obj = null
      beforeEach ->
        obj = new WhitelistObject("p", null, ["normal", "highlighted"])

      it "adds the string of classes", ->
        obj.addClasses("just testing")
        expect(obj.classes).toEqual("highlighted just normal testing")

      it "adds the array of classes", ->
        obj.addClasses(["just", "testing"])
        expect(obj.classes).toEqual("highlighted just normal testing")

      it "removes duplicates", ->
        obj.addClasses("just normal")
        expect(obj.classes).toEqual("highlighted just normal")

      it "does nothing when there are no classes to add", ->
        obj.addClasses([])
        expect(obj.classes).toEqual("highlighted normal")

    describe "#addAttributes", ->
      obj = null
      beforeEach ->
        obj = new WhitelistObject("p", null, [], ["width", "height"])

      it "adds the array of attributes", ->
        obj.addAttributes(["style", "selected"])
        expect(obj.attrs["width"]).toBeTruthy()
        expect(obj.attrs["height"]).toBeTruthy()
        expect(obj.attrs["style"]).toBeTruthy()
        expect(obj.attrs["selected"]).toBeTruthy()

      it "adds the object of attributes", ->
        obj.addAttributes(style: true, selected: true)
        expect(obj.attrs["width"]).toBeTruthy()
        expect(obj.attrs["height"]).toBeTruthy()
        expect(obj.attrs["style"]).toBeTruthy()
        expect(obj.attrs["selected"]).toBeTruthy()

      it "removes duplicates", ->
        obj.addAttributes(["style", "width"])
        expect(obj.attrs["width"]).toBeTruthy()
        expect(obj.attrs["height"]).toBeTruthy()
        expect(obj.attrs["style"]).toBeTruthy()

    describe "#addValues", ->
      obj = null
      beforeEach ->
        obj = new WhitelistObject("p", null, [], [], styles: ["width", "height"])

      it "adds the object of arrays of values", ->
        obj.addValues(
          testing: ["one", "two"]
          styles: ["font-size"]
        )
        expect(obj.values.testing).toBeDefined()
        expect(obj.values.testing.one).toBeTruthy()
        expect(obj.values.testing.two).toBeTruthy()
        expect(obj.values.styles.width).toBeTruthy()
        expect(obj.values.styles.height).toBeTruthy()
        expect(obj.values.styles["font-size"]).toBeTruthy()

      it "adds the object of objects of values", ->
        obj.addValues(
          testing:
            one: true
            two: true
          styles:
            "font-size": true
        )
        expect(obj.values.testing).toBeDefined()
        expect(obj.values.testing.one).toBeTruthy()
        expect(obj.values.testing.two).toBeTruthy()
        expect(obj.values.styles.width).toBeTruthy()
        expect(obj.values.styles.height).toBeTruthy()
        expect(obj.values.styles["font-size"]).toBeTruthy()

      it "removes duplicates", ->
        obj.addValues(
          testing: ["one", "two"]
          styles: ["font-size", "width"]
        )
        expect(obj.values.testing).toBeDefined()
        expect(obj.values.testing.one).toBeTruthy()
        expect(obj.values.testing.two).toBeTruthy()
        expect(obj.values.styles.width).toBeTruthy()
        expect(obj.values.styles.height).toBeTruthy()
        expect(obj.values.styles["font-size"]).toBeTruthy()

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

      it "builds an element with the given tag and all styles", ->
        obj = new WhitelistObject("p", null, [], ["width", "style"])
        $el = $(obj.getElement(document, $('<div width="100px" style="background-color: pink; text-align: left;"/>')[0]))
        expect($el.tagName()).toEqual("p")
        expect($el.attr("width")).toEqual("100px")
        if isIE9 or isIE10
          expect($el.attr("style")).toEqual("text-align: left; background-color: pink;")
        else if isIE
          expect($el.attr("style")).toEqual("text-align: left; background-color: pink")
        else
          expect($el.attr("style")).toEqual("background-color: pink; text-align: left;")

      it "builds an element with the given tag and styles", ->
        obj = new WhitelistObject("p", null, [], ["width", "style"], { style: ["font-size", "text-align"] })
        $el = $(obj.getElement(document, $('<div width="100px" style="font-size: 12px; text-align: left; color: pink;"/>')[0]))
        expect($el.tagName()).toEqual("p")
        expect($el.attr("width")).toEqual("100px")
        if isIE9 or isIE10
          expect($.trim($el.attr("style"))).toEqual("text-align: left; font-size: 12px;")
        else if isIE
          expect($.trim($el.attr("style"))).toEqual("text-align: left; font-size: 12px")
        else
          expect($.trim($el.attr("style"))).toEqual("font-size: 12px; text-align: left;")

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

    describe "#valuesAllowed", ->
      obj = null
      beforeEach ->
        obj = new WhitelistObject("p", null, [], ["style"], { style: ["background", "text-align"] })

      it "throws when not a style attribute", ->
        expect(-> obj.valuesAllowed("width", "")).toThrow()

      it "returns true when there are no values", ->
        expect(obj.valuesAllowed("style", "")).toBeTruthy()

      it "returns true when the value is allowed", ->
        expect(obj.valuesAllowed("style", "background: url('image.png')")).toBeTruthy()

      it "returns true when the values are allowed", ->
        expect(obj.valuesAllowed("style", "background: url('image.png'); text-align: left;")).toBeTruthy()

      it "returns false when the value is not allowed", ->
        expect(obj.valuesAllowed("style", "background: url('image.png'); text-align: left; color: pink")).toBeFalsy()

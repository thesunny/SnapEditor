require ["jquery.custom", "core/whitelist/whitelist.object"], ($, WhitelistObject) ->
  describe "Whitelist.Object", ->
    describe "#constructor", ->
      it "sorts the classes alphabetically", ->
        obj = new WhitelistObject("p", ["normal", "highlighted"])
        expect(obj.classes).toEqual(["highlighted", "normal"])

    describe "#getElement", ->
      it "builds an element with the given tag and no classes", ->
        obj = new WhitelistObject("p", [])
        $el = $(obj.getElement())
        expect($el.tagName()).toEqual("p")
        expect($el.attr("class")).toBeUndefined()

      it "builds an element with the given tag and classes", ->
        obj = new WhitelistObject("p", ["normal", "highlighted"])
        $el = $(obj.getElement())
        expect($el.tagName()).toEqual("p")
        expect($el.attr("class")).toEqual("highlighted normal")

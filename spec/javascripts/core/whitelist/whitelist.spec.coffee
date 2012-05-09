require ["jquery.custom", "core/whitelist/whitelist"], ($, Whitelist) ->
  describe "Whitelist", ->
    describe "#allowed", ->
      whitelist = null
      beforeEach ->
        whitelist = new Whitelist(Title: "h1.title > p")

      it "returns true when the element is allowed", ->
        expect(whitelist.allowed($('<h1 class="title"></h1>'))).toBeTruthy()

      it "returns false when the element is not allowed", ->
        expect(whitelist.allowed($('<h1 class="almost"></h1>'))).toBeFalsy()

    describe "#replacement", ->
      whitelist = null
      beforeEach ->
        whitelist = new Whitelist(
          Title: "h1.title > p"
          Subtitle: "h2"
          Normal: "div.normal"
          "h2": "Subtitle"
          "*": "Normal"
        )

      it "returns the default for the tag when it exists", ->
        $replacement = $(whitelist.replacement($('<h2 class="subtitle"></h2>')))
        expect($replacement.tagName()).toEqual("h2")
        expect($replacement.attr("class")).toBeUndefined()

      it "returns the first object in the whitelist by tag when the default does not exist", ->
        $replacement = $(whitelist.replacement($('<h1 class="subtitle"></h1>')))
        expect($replacement.tagName()).toEqual("h1")
        expect($replacement.attr("class")).toEqual("title")

      it "returns the general default when there is no object for the tag", ->
        $replacement = $(whitelist.replacement($('<h3 class="subsubtitle"></h3>')))
        expect($replacement.tagName()).toEqual("div")
        expect($replacement.attr("class")).toEqual("normal")

    describe "#next", ->
      whitelist = null
      beforeEach ->
        whitelist = new Whitelist(
          Title: "h1.title > p"
          Subtitle: "h1.subtitle"
          Normal: "div.normal"
          "*": "Normal"
        )

      it "returns the object when it exists", ->
        $next = $(whitelist.next($('<h1 class="title"></h1>')))
        expect($next.tagName()).toEqual("p")
        expect($next.attr("class")).toBeUndefined()

      it "returns the default when none exists", ->
        $next = $(whitelist.next($('<h1 class="subtitle"></h1>')))
        expect($next.tagName()).toEqual("div")
        expect($next.attr("class")).toEqual("normal")

    describe "#match", ->
      whitelist = null
      beforeEach ->
        whitelist = new Whitelist(Title: "h1.title > p")

      it "returns the matched object", ->
        match = whitelist.match($('<h1 class="title">Title</h1>'))
        expect(match.tag).toEqual("h1")
        expect(match.classes).toEqual(["title"])
        expect(match.next.tag).toEqual("p")
        expect(match.next.classes).toEqual([])

      it "returns null when the class does not match", ->
        expect(whitelist.match($('<h1 class="almost">Title</h1>'))).toBeNull()

      it "returns null when the tag does not match", ->
        expect(whitelist.match($('<h2 class="almost">Title</h2>'))).toBeNull()

      it "handles elements with no classes appropriately", ->
        expect(whitelist.match($('<h1>Title</h1>'))).toBeNull()

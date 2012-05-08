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
        expect(whitelist.replacement($('<h2 class="subtitle"></h2>'))).toEqual(tag: "h2", classes: [])

      it "returns the first object in the whitelist by tag when the default does not exist", ->
        expect(whitelist.replacement($('<h1 class="subtitle"></h1>'))).toEqual(tag: "h1", classes: ["title"], next: { tag: "p", classes: []})

      it "returns the general default when there is no object for the tag", ->
        expect(whitelist.replacement($('<h3 class="subsubtitle"></h3>'))).toEqual(tag: "div", classes: ["normal"])

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
        expect(whitelist.next($('<h1 class="title"></h1>'))).toEqual(tag: "p", classes: [])

      it "returns the default when none exists", ->
        expect(whitelist.next($('<h1 class="subtitle"></h1>'))).toEqual(tag: "div", classes: ["normal"])

    describe "#match", ->
      whitelist = null
      beforeEach ->
        whitelist = new Whitelist(Title: "h1.title > p")

      it "returns true when the element is allowed", ->
        expect(whitelist.match($('<h1 class="title">Title</h1>'))).toEqual(tag: "h1", classes: ["title"], next: { tag: "p", classes: [] })

      it "returns false when the element is not allowed", ->
        expect(whitelist.match($('<h1 class="almost">Title</h1>'))).toBeNull()

      it "returns false when the element's tag is not in the whitelist", ->
        expect(whitelist.match($('<h2 class="almost">Title</h2>'))).toBeNull()

      it "handles elements with no classes appropriately", ->
        expect(whitelist.match($('<h1>Title</h1>'))).toBeNull()

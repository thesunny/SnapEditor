require ["core/whitelist/whitelist.generator"], (Generator) ->
  describe "Whitelist.Generator", ->
    generator = null
    beforeEach ->
      generator = new Generator()

    describe "#generateWhitelists", ->
      beforeEach ->
        generator.whitelist =
          Title: "h1.title > Subtitle"
          Subtitle: "h1.title > Normal"
          "Heading 1": "h1 > Normal"
          "Bullet List": "ul"
          "Highlighted List Item": "li.highlight.focus > li"
          Normal: "p"
          "li": "Highlighted List Item"
          "*": "Normal"
        generator.generateWhitelists()

      it "generates the defaults", ->
        defaults = generator.defaults
        expect(defaults.li).toEqual(
          tag: "li"
          classes: ["focus", "highlight"]
          next:
            tag: "li"
            classes: []
        )
        expect(defaults["*"]).toEqual(
          tag: "p"
          classes: []
        )

      it "generates the whitelist by label", ->
        list = generator.whitelistByLabel
        expect(list.Title).toEqual(
          tag: "h1"
          classes: ["title"]
          next:
            tag: "h1"
            classes: ["title"]
            next:
              tag: "p"
              classes: []
        )
        expect(list.Subtitle).toEqual(
          tag: "h1"
          classes: ["title"]
          next:
            tag: "p"
            classes: []
        )
        expect(list["Heading 1"]).toEqual(
          tag: "h1"
          classes: []
          next:
            tag: "p"
            classes: []
        )
        expect(list["Bullet List"]).toEqual(
          tag: "ul"
          classes: []
        )
        expect(list["Highlighted List Item"]).toEqual(
          tag: "li"
          classes: ["focus", "highlight"]
          next:
            tag: "li"
            classes: []
        )
        expect(list.Normal).toEqual(
          tag: "p"
          classes: []
        )

      it "generates the whitelist by tag", ->
        list = generator.whitelistByTag
        expect(list.h1).toEqual([
          {
            tag: "h1"
            classes: ["title"]
            next:
              tag: "h1"
              classes: ["title"]
              next:
                tag: "p"
                classes: []
          }
          {
            tag: "h1"
            classes: ["title"]
            next:
              tag: "p"
              classes: []
          }
          {
            tag: "h1"
            classes: []
            next:
              tag: "p"
              classes: []
          }
        ])
        expect(list.ul).toEqual([
          { tag: "ul", classes: [] }
        ])
        expect(list.p).toEqual([
          { tag: "p", classes: []}
        ])

    describe "#isLabel", ->
      it "returns true when the label starts with a capital", ->
        expect(generator.isLabel("Normal")).toBeTruthy()

      it "returns false when the label starts with a lowercase", ->
        expect(generator.isLabel("normal")).toBeFalsy()

    describe "#parse", ->
      it "parses a single tag", ->
        obj = generator.parse("p")
        expect(obj.tag).toEqual("p")
        expect(obj.classes).toEqual([])
        expect(obj.next).toBeUndefined()

      it "parses a single class", ->
        obj = generator.parse("p.normal")
        expect(obj.tag).toEqual("p")
        expect(obj.classes).toEqual(["normal"])
        expect(obj.next).toBeUndefined()

      it "parses multiple classes and sorts them", ->
        obj = generator.parse("p.normal.highlighted")
        expect(obj.tag).toEqual("p")
        expect(obj.classes).toEqual(["highlighted", "normal"])
        expect(obj.next).toBeUndefined()

      it "parses an next tag", ->
        obj = generator.parse("p > div")
        expect(obj.tag).toEqual("p")
        expect(obj.classes).toEqual([])
        expect(obj.next).toEqual(tag: "div", classes: [])

      it "parses an next tag with a single class", ->
        obj = generator.parse("p > div.simple")
        expect(obj.tag).toEqual("p")
        expect(obj.classes).toEqual([])
        expect(obj.next).toEqual(tag: "div", classes: ["simple"])

      it "parses an next tag with multiple classes", ->
        obj = generator.parse("p > div.simple.highlighted")
        expect(obj.tag).toEqual("p")
        expect(obj.classes).toEqual([])
        expect(obj.next).toEqual(tag: "div", classes: ["highlighted", "simple"])

      it "parses an next with a label", ->
        obj = generator.parse("p > Block")
        expect(obj.tag).toEqual("p")
        expect(obj.classes).toEqual([])
        expect(obj.next).toEqual("Block")

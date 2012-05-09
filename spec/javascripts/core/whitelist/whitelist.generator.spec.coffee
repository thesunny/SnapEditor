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
        expect(defaults.li.tag).toEqual("li")
        expect(defaults.li.classes).toEqual(["focus", "highlight"])
        expect(defaults.li.next.tag).toEqual("li")
        expect(defaults.li.next.classes).toEqual([])
        expect(defaults["*"].tag).toEqual("p")
        expect(defaults["*"].classes).toEqual([])

      it "generates the whitelist by label", ->
        list = generator.whitelistByLabel
        expect(list.Title.tag).toEqual("h1")
        expect(list.Title.classes).toEqual(["title"])
        expect(list.Title.next.tag).toEqual("h1")
        expect(list.Title.next.classes).toEqual(["title"])
        expect(list.Title.next.next.tag).toEqual("p")
        expect(list.Title.next.next.classes).toEqual([])
        expect(list.Subtitle.tag).toEqual("h1")
        expect(list.Subtitle.classes).toEqual(["title"])
        expect(list.Subtitle.next.tag).toEqual("p")
        expect(list.Subtitle.next.classes).toEqual([])
        expect(list["Heading 1"].tag).toEqual("h1")
        expect(list["Heading 1"].classes).toEqual([])
        expect(list["Heading 1"].next.tag).toEqual("p")
        expect(list["Heading 1"].next.classes).toEqual([])
        expect(list["Bullet List"].tag).toEqual("ul")
        expect(list["Bullet List"].classes).toEqual([])
        expect(list["Highlighted List Item"].tag).toEqual("li")
        expect(list["Highlighted List Item"].classes).toEqual(["focus", "highlight"])
        expect(list["Highlighted List Item"].next.tag).toEqual("li")
        expect(list["Highlighted List Item"].next.classes).toEqual([])
        expect(list.Normal.tag).toEqual("p")
        expect(list.Normal.classes).toEqual([])

      it "generates the whitelist by tag", ->
        list = generator.whitelistByTag
        expect(list.h1[0].tag).toEqual("h1")
        expect(list.h1[0].classes).toEqual(["title"])
        expect(list.h1[0].next.tag).toEqual("h1")
        expect(list.h1[0].next.classes).toEqual(["title"])
        expect(list.h1[0].next.next.tag).toEqual("p")
        expect(list.h1[0].next.next.classes).toEqual([])
        expect(list.h1[1].tag).toEqual("h1")
        expect(list.h1[1].classes).toEqual(["title"])
        expect(list.h1[1].next.tag).toEqual("p")
        expect(list.h1[1].next.classes).toEqual([])
        expect(list.h1[2].tag).toEqual("h1")
        expect(list.h1[2].classes).toEqual([])
        expect(list.h1[2].next.tag).toEqual("p")
        expect(list.h1[2].next.classes).toEqual([])
        expect(list.ul[0].tag).toEqual("ul")
        expect(list.ul[0].classes).toEqual([])
        expect(list.p[0].tag).toEqual("p")
        expect(list.p[0].classes).toEqual([])

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
        expect(obj.next.tag).toEqual("div")
        expect(obj.next.classes).toEqual([])

      it "parses an next tag with a single class", ->
        obj = generator.parse("p > div.simple")
        expect(obj.tag).toEqual("p")
        expect(obj.classes).toEqual([])
        expect(obj.next.tag).toEqual("div")
        expect(obj.next.classes).toEqual(["simple"])

      it "parses an next tag with multiple classes", ->
        obj = generator.parse("p > div.simple.highlighted")
        expect(obj.tag).toEqual("p")
        expect(obj.classes).toEqual([])
        expect(obj.next.tag).toEqual("div")
        expect(obj.next.classes).toEqual(["highlighted", "simple"])

      it "parses an next with a label", ->
        obj = generator.parse("p > Block")
        expect(obj.tag).toEqual("p")
        expect(obj.classes).toEqual([])
        expect(obj.next).toEqual("Block")

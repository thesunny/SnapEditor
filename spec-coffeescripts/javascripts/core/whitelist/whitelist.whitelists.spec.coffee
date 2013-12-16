# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["core/whitelist/whitelist.whitelists"], (Whitelists) ->
  describe "Whitelist.Whitelists", ->
    whitelists = null
    beforeEach ->
      whitelists = new Whitelists(
        Title: "h1.title > Subtitle"
        Subtitle: "h1.subtitle > Normal"
        "Heading 1": "h1 > Normal"
        "Bullet List": "ul"
        "Highlighted List Item": "li.highlight.focus > Highlighted List Item"
        Normal: "p"
        "li": "Highlighted List Item"
        "b": "b"
        "*": "Normal"
      )

    describe "#add", ->
      it "generates the defaults", ->
        defaults = whitelists.defaults
        expect(defaults.li).toEqual("Highlighted List Item")
        expect(defaults.b).toEqual("B")
        expect(defaults["*"]).toEqual("Normal")

      it "generates the whitelist by label", ->
        list = whitelists.byLabel
        expect(list.Title.tag).toEqual("h1")
        expect(list.Title.classes).toEqual("title")
        expect(list.Title.next).toEqual("Subtitle")
        expect(list.Subtitle.tag).toEqual("h1")
        expect(list.Subtitle.classes).toEqual("subtitle")
        expect(list.Subtitle.next).toEqual("Normal")
        expect(list["Heading 1"].tag).toEqual("h1")
        expect(list["Heading 1"].classes).toEqual("")
        expect(list["Heading 1"].next).toEqual("Normal")
        expect(list["Bullet List"].tag).toEqual("ul")
        expect(list["Bullet List"].classes).toEqual("")
        expect(list["Highlighted List Item"].tag).toEqual("li")
        expect(list["Highlighted List Item"].classes).toEqual("focus highlight")
        expect(list["Highlighted List Item"].next).toEqual("Highlighted List Item")
        expect(list.B.tag).toEqual("b")
        expect(list.Normal.tag).toEqual("p")
        expect(list.Normal.classes).toEqual("")

      it "generates the whitelist by tag", ->
        list = whitelists.byTag
        expect(list.h1[0].tag).toEqual("h1")
        expect(list.h1[0].classes).toEqual("title")
        expect(list.h1[0].next).toEqual("Subtitle")
        expect(list.h1[1].tag).toEqual("h1")
        expect(list.h1[1].classes).toEqual("subtitle")
        expect(list.h1[1].next).toEqual("Normal")
        expect(list.h1[2].tag).toEqual("h1")
        expect(list.h1[2].classes).toEqual("")
        expect(list.h1[2].next).toEqual("Normal")
        expect(list.ul[0].tag).toEqual("ul")
        expect(list.ul[0].classes).toEqual("")
        expect(list.b[0].tag).toEqual("b")
        expect(list.p[0].tag).toEqual("p")
        expect(list.p[0].classes).toEqual("")

      it "handles duplicate labels", ->
        prevObj = whitelists.byLabel["Title"]
        whitelists.add("Title", "p.title")
        expect(whitelists.byLabel["Title"].tag).toEqual("p")
        expect(whitelists.byLabel["Title"].classes).toEqual("title")
        expect(whitelists.byLabel["Title"].next).not.toBeDefined()
        expect($.inArray(whitelists.byLabel["Title"], whitelists.byTag["p"])).toBeGreaterThan(-1)
        expect($.inArray(prevObj, whitelists.byTag["h1"])).toEqual(-1)

    describe "#addGeneralRule", ->
      beforeEach ->
        whitelists.addGeneralRule(".general[style=(text-align)]", ["h1", "li"])

      it "adds the rule to the general list", ->
        expect(whitelists.general.h1.length).toEqual(1)
        expect(whitelists.general.h1[0].tag).toEqual("")
        expect(whitelists.general.h1[0].classes).toEqual("general")
        expect(whitelists.general.h1[0].attrs.style).toBeTruthy()
        expect(whitelists.general.h1[0].values.style["text-align"]).toBeTruthy()
        expect(whitelists.general.li.length).toEqual(1)
        expect(whitelists.general.li[0]).toBe(whitelists.general.h1[0])

      it "doesn't add duplicates", ->
        whitelists.addGeneralRule(".general[style=(text-align)]", ["h1", "li", "td"])
        expect(whitelists.general.h1.length).toEqual(1)
        expect(whitelists.general.li.length).toEqual(1)
        expect(whitelists.general.td.length).toEqual(1)
        expect(whitelists.general.td[0]).not.toBe(whitelists.general.h1[0])
        expect(whitelists.general.td[0].tag).toEqual("")
        expect(whitelists.general.td[0].classes).toEqual("general")
        expect(whitelists.general.td[0].attrs.style).toBeTruthy()
        expect(whitelists.general.td[0].values.style["text-align"]).toBeTruthy()

    describe "#matchByElement", ->
      it "returns the matched object", ->
        expect(whitelists.matchByElement($('<h1 class="title">Title</h1>')[0])).not.toBeNull()

      it "returns null when a match is not found", ->
        expect(whitelists.matchByElement($('<h1 class="almost">Title</h1>')[0])).toBeNull()

    describe "#isLabel", ->
      it "returns true when the label starts with a capital", ->
        expect(whitelists.isLabel("Normal")).toBeTruthy()

      it "returns false when the label starts with a lowercase", ->
        expect(whitelists.isLabel("normal")).toBeFalsy()

    describe "#parse", ->
      it "parses a single tag", ->
        obj = whitelists.parse("p")
        expect(obj.tag).toEqual("p")
        expect(obj.id).toBeNull()
        expect(obj.classes).toEqual("")
        expect(obj.attrs).toEqual([])
        expect(obj.next).toBeUndefined()

      it "parses the id", ->
        obj = whitelists.parse("p#special")
        expect(obj.tag).toEqual("p")
        expect(obj.id).toEqual("special")
        expect(obj.classes).toEqual("")
        expect(obj.attrs).toEqual([])
        expect(obj.next).toBeUndefined()

      it "parses a single class", ->
        obj = whitelists.parse("p.normal")
        expect(obj.tag).toEqual("p")
        expect(obj.id).toBeNull()
        expect(obj.classes).toEqual("normal")
        expect(obj.attrs).toEqual([])
        expect(obj.next).toBeUndefined()

      it "parses multiple classes and sorts them", ->
        obj = whitelists.parse("p.normal.highlighted")
        expect(obj.tag).toEqual("p")
        expect(obj.id).toBeNull()
        expect(obj.classes).toEqual("highlighted normal")
        expect(obj.attrs).toEqual([])
        expect(obj.next).toBeUndefined()

      it "parses just a class", ->
        obj = whitelists.parse(".normal")
        expect(obj.tag).toEqual("")
        expect(obj.id).toBeNull()
        expect(obj.classes).toEqual("normal")
        expect(obj.attrs).toEqual([])
        expect(obj.next).toBeUndefined()

      it "parses attributes", ->
        obj = whitelists.parse("p[width,height]")
        expect(obj.tag).toEqual("p")
        expect(obj.id).toBeNull()
        expect(obj.classes).toEqual("")
        expect(obj.attrs).toEqual(width: true, height: true)
        expect(obj.next).toBeUndefined()

      it "parses just attributes", ->
        obj = whitelists.parse("[width,height]")
        expect(obj.tag).toEqual("")
        expect(obj.id).toBeNull()
        expect(obj.classes).toEqual("")
        expect(obj.attrs).toEqual(width: true, height: true)
        expect(obj.next).toBeUndefined()

      it "parses values", ->
        obj = whitelists.parse("p[width,height,style=(background|text-align)]")
        expect(obj.tag).toEqual("p")
        expect(obj.id).toBeNull()
        expect(obj.classes).toEqual("")
        expect(obj.attrs).toEqual(width: true, height: true, style: true)
        expect(obj.values).toEqual(
          style:
            background: true
            "text-align": true
        )

      it "parses classes, attributes, and values together", ->
        obj = whitelists.parse(".normal.highlighted[width,height,style=(background|text-align)]")
        expect(obj.tag).toEqual("")
        expect(obj.id).toBeNull()
        expect(obj.classes).toEqual("highlighted normal")
        expect(obj.attrs).toEqual(width: true, height: true, style: true)
        expect(obj.values).toEqual(
          style:
            background: true
            "text-align": true
        )
        expect(obj.next).toBeUndefined()

      it "parses the id, classes, attributes, and values together", ->
        obj = whitelists.parse("p#special.normal.highlighted[width,height, style=(background|text-align)]")
        expect(obj.tag).toEqual("p")
        expect(obj.id).toEqual("special")
        expect(obj.classes).toEqual("highlighted normal")
        expect(obj.attrs).toEqual(width: true, height: true, style: true)
        expect(obj.values).toEqual(
          style:
            background: true
            "text-align": true
        )
        expect(obj.next).toBeUndefined()

      it "parses a full string", ->
        obj = whitelists.parse("p#special.normal.highlighted[width,height,style=(background|text-align)] > Simple")
        expect(obj.tag).toEqual("p")
        expect(obj.id).toEqual("special")
        expect(obj.classes).toEqual("highlighted normal")
        expect(obj.attrs).toEqual(width: true, height: true, style: true)
        expect(obj.values).toEqual(
          style:
            background: true
            "text-align": true
        )
        expect(obj.next).toEqual("Simple")

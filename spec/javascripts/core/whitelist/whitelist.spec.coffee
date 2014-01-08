# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "core/whitelist/whitelist"], ($, Whitelist) ->
  describe "Whitelist", ->
    describe "#isAllowed", ->
      whitelist = null
      beforeEach ->
        whitelist = new Whitelist(
          Normal: "p"
          Title: "h1.title > Normal"
        )

      it "returns true when the element is allowed", ->
        expect(whitelist.isAllowed($('<h1 class="title"></h1>')[0])).toBeTruthy()

      it "returns false when the element is not allowed", ->
        expect(whitelist.isAllowed($('<h1 class="almost"></h1>')[0])).toBeFalsy()

    describe "#getReplacement", ->
      $editable = whitelist = null
      beforeEach ->
        $editable = addEditableFixture()
        whitelist = new Whitelist(
          Title: "h1.title > Normal"
          Subtitle: "h2"
          Normal: "div.normal"
          "h2": "Subtitle"
          "*": "Normal"
        )

      afterEach ->
        $editable.remove()

      it "returns the default for the tag when it exists", ->
        $replacement = $(whitelist.getReplacement($('<h2 class="subtitle"></h2>')[0]))
        expect($replacement.tagName()).toEqual("h2")
        expect($replacement.attr("class")).toBeUndefined()

      it "returns the first object in the whitelist by tag when the default does not exist", ->
        $replacement = $(whitelist.getReplacement($('<h1 class="subtitle"></h1>')[0]))
        expect($replacement.tagName()).toEqual("h1")
        expect($replacement.attr("class")).toEqual("title")

      it "returns the default block when there is no replacement for the block tag", ->
        $replacement = $(whitelist.getReplacement($("<p/>").appendTo($editable)[0]))
        expect($replacement.tagName()).toEqual("div")
        expect($replacement.attr("class")).toEqual("normal")

      it "returns null when there is no replacement for the inline tag", ->
        expect(whitelist.getReplacement($("<span/>").appendTo($editable)[0])).toBeNull()

    describe "#getNext", ->
      whitelist = null
      beforeEach ->
        whitelist = new Whitelist(
          Title: "h1.title > Normal"
          Subtitle: "h1.subtitle > h1.subtitle"
          Normal: "div.normal"
          "*": "Normal"
        )

      it "returns the object when it exists", ->
        $next = $(whitelist.getNext($('<h1 class="title"></h1>')[0]))
        expect($next.tagName()).toEqual("div")
        expect($next.attr("class")).toEqual("normal")

      it "returns the object when it is itself", ->
        $next = $(whitelist.getNext($('<h1 class="subtitle"></h1>')[0]))
        expect($next.tagName()).toEqual("h1")
        expect($next.attr("class")).toEqual("subtitle")

      it "returns the default when none exists", ->
        $next = $(whitelist.getNext($('<div class="normal"></h1>')[0]))
        expect($next.tagName()).toEqual("div")
        expect($next.attr("class")).toEqual("normal")

    describe "#getReplacementByTag", ->
      whitelist = null
      beforeEach ->
        whitelist = new Whitelist(
          Normal: "p"
          "Super Title": "h1#super.title"
          Title: "h1.title > Normal"
          Heading: "h1.heading > Normal"
          "Special Subtitle": "h2#special.subtitle"
          "Normal Subtitle": "h2#normal.subtitle"
        )

      it "returns null if the tag is not in the list", ->
        expect(whitelist.getReplacementByTag("li")).toBeNull()

      it "returns null if the objects all have ids", ->
        expect(whitelist.getReplacementByTag("h2")).toBeNull()

      it "returns the first object without an id", ->
        replacement = whitelist.getReplacementByTag("h1")
        expect(replacement.id).toBeNull()
        expect(replacement.classes).toEqual("title")

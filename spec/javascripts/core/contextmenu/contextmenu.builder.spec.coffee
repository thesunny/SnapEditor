# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "core/contextmenu/contextmenu.builder"], ($, Builder) ->
  describe "ContextMenu.Builder", ->
    builder = null
    beforeEach ->
      component =
        htmlForContextMenu: -> "html"
        cssForContextMenu: -> "test {position: absolute}"
      buttons =
        list: [component]
        table: [component, component]
      builder = new Builder(null, buttons)

    describe "#getComponents", ->
      beforeEach ->
        spyOn(builder, "generateHTMLForContext").andReturn("html")

      it "returns the components for each group", ->
        components = builder.getComponents(["list", "table"])
        expect(components.length).toEqual(2)
        expect(components[0].html).toEqual("html")
        expect(components[1].html).toEqual("html")

      it "flags the last component", ->
        components = builder.getComponents(["list", "table"])
        expect(components[1].last).toBeTruthy()

    describe "#generateHTMLForContext", ->
      afterEach ->
        $("styles").last().remove()

      it "generates the HTML", ->
        html = builder.generateHTMLForContext("table")
        expect(html).toEqual("htmlhtml")

      it "caches the generated HTML", ->
        html = builder.generateHTMLForContext("table")
        expect(builder.contextHTML["table"]).toEqual("htmlhtml")

      it "inserts the styles", ->
        html = builder.generateHTMLForContext("table")
        expect(clean($("head").find("style").last().html())).toEqual("test {position: absolute}test {position: absolute}")

      it "returns an empty string for default when it doesn't exist", ->
        html = builder.generateHTMLForContext("default")
        expect(html).toEqual("")

      it "throws an error when the context does not exist", ->
        expect(-> builder.generateHTMLForContext("test")).toThrow()

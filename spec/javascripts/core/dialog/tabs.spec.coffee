# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "core/dialog/tabs"], ($, Tabs) ->
  describe "Tabs", ->
    $container = tabs = null
    beforeEach ->
      $container = $("<div/>").prependTo("body")
      tabs = new Tabs()

    afterEach ->
      $container.remove()

    describe "#add", ->
      it "adds the content to the list", ->
        $content = $("<div/>")
        tabs.add($content, "Test")
        expect(tabs.contents.length).toEqual(1)
        expect(tabs.contents[0].title).toEqual("Test")
        expect(tabs.contents[0].$el[0]).toBe($content[0])

    describe "#insert", ->
      it "does nothing when there is no content", ->
        tabs.insert($container)
        expect($container.children().length).toEqual(0)

      describe "one content", ->
        $content = null
        beforeEach ->
          $content = $("<div/>")
          tabs.add($content, "Content")
          tabs.insert($container)

        it "does not insert tabs", ->
          expect($(".snapeditor_tabs").length).toEqual(0)

        it "inserts a content container", ->
          expect($container.children().length).toEqual(1)
          expect($($container.children()[0]).hasClass("snapeditor_tabs_content")).toBeTruthy()

        it "shows the content", ->
          $contents = $(".snapeditor_tabs_content").children()
          expect($contents.length).toEqual(1)
          expect($contents[0]).toBe($content[0])
          expect($($contents[0]).css("display")).toEqual("block")

      describe "multiple contents", ->
        $content1 = $content2 = null
        beforeEach ->
          $content1 = $("<div/>")
          $content2 = $("<div/>")
          tabs.add($content1, "Content 1")
          tabs.add($content2, "Content 2")
          tabs.insert($container)

        it "inserts tabs", ->
          expect($(".snapeditor_tabs").length).toEqual(1)

        it "inserts a content container", ->
          expect($(".snapeditor_tabs_content").length).toEqual(1)

        it "inserts the contents", ->
          $contents = $(".snapeditor_tabs_content").children()
          expect($contents.length).toEqual(2)
          expect($contents[0]).toBe($content1[0])
          expect($contents[1]).toBe($content2[0])

        it "shows the first content", ->
          expect($($(".snapeditor_tabs_content").children()[0]).css("display")).toEqual("block")

        it "hides the other content", ->
          expect($($(".snapeditor_tabs_content").children()[1]).css("display")).toEqual("none")

    describe "#insertTabs", ->
      $contentContainer = null
      beforeEach ->
        $contentContainer = $("<div/>").appendTo($container)
        $content1 = $("<div/>")
        $content2 = $("<div/>")
        tabs.add($content1, "Content 1")
        tabs.add($content2, "Content 2")
        tabs.insertTabs($contentContainer)

      it "inserts a tab container before the content container", ->
        expect($container.children().length).toEqual(2)
        expect($($container.children()[0]).hasClass("snapeditor_tabs")).toBeTruthy()

      it "creates the tabs", ->
        $tabs = $(".snapeditor_tabs").children()
        expect($tabs.length).toEqual(2)
        expect($($tabs[0]).find("a").length).toEqual(1)
        expect($($tabs[0]).find("a").html()).toEqual("Content 1")
        expect($($tabs[1]).find("a").length).toEqual(1)
        expect($($tabs[1]).find("a").html()).toEqual("Content 2")

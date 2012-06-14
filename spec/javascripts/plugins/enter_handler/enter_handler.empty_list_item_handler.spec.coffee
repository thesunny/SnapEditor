require ["jquery.custom", "plugins/enter_handler/enter_handler.empty_list_item_handler", "core/helpers", "core/range"], ($, Handler, Helpers, Range) ->
  describe "EnterHandler.EmptyListItemHandler", ->
    $editable = $ul = handler = null
    beforeEach ->
      $editable = addEditableFixture().html("
        <ul>
          <li>1</li>
          <li>2</li>
          <li>3</li>
        </ul>
      ")
      $ul = $editable.find("ul")
      api =
        blankRange: -> new Range($editable[0])
        next: -> $("<p/>")
      Helpers.delegate(api, "blankRange()", "selectEndOfElement")
      handler = new Handler(api)

    afterEach ->
      $editable.remove()

    describe "#handle", ->
      describe "top-level item", ->
        describe "first item", ->
          it "removes the item and adds the next block before the list", ->
            handler.handle($ul.find("li").first())
            expect($ul.find("li").length).toEqual(2)
            expect($editable.children().first().tagName()).toEqual("p")

          it "removes the list if there is only 1 item", ->
            $($ul.find("li")[2]).remove()
            $($ul.find("li")[1]).remove()
            handler.handle($ul.find("li").first())
            expect($editable.find("ul").length).toEqual(0)
            expect($editable.find("p").length).toEqual(1)

        describe "middle item", ->
          beforeEach ->
            handler.handle($ul.find("li")[1])

          it "splits the list in two", ->
            expect($editable.find("ul").length).toEqual(2)
            expect($editable.find("ul").first().find("li").length).toEqual(1)
            expect($editable.find("ul").first().find("li").html()).toEqual("1")
            expect($editable.find("ul").last().find("li").length).toEqual(1)
            expect($editable.find("ul").last().find("li").html()).toEqual("3")

          it "replaces the item with the next block in between the two lists", ->
            $children = $editable.children()
            expect($($children[0]).tagName()).toEqual("ul")
            expect($($children[1]).tagName()).toEqual("p")
            expect($($children[2]).tagName()).toEqual("ul")

        describe "last item", ->
          it "removes the item and adds the next block after the list", ->
            handler.handle($ul.find("li").last())
            expect($editable.find("ul").find("li").length).toEqual(2)
            expect($editable.children().last().tagName()).toEqual("p")

          it "keeps the order of the previous items", ->
            handler.handle($ul.find("li").last())
            $lis = $editable.find("li")
            expect($lis[0].innerHTML).toEqual("1")
            expect($lis[1].innerHTML).toEqual("2")

          it "removes the list if there is only 1 item", ->
            $($ul.find("li")[2]).remove()
            $($ul.find("li")[1]).remove()
            handler.handle($ul.find("li").first())
            expect($editable.find("ul").length).toEqual(0)
            expect($editable.find("p").length).toEqual(1)

      describe "inner item", ->
        $ul = $ol = null
        beforeEach ->
          $editable.html("
            <ul>
              <li>1</li>
              <ol>
                <li>1.1</li>
                <li>1.2</li>
                <li>1.3</li>
              </ol>
              <li>2</li>
              <li>3</li>
            </ul>
          ")
          $ul = $editable.find("ul")
          $ol = $editable.find("ol")

        describe "first item", ->
          it "moves the item to the parent list", ->
            handler.handle($ol.find("li").first())
            expect($ol.find("li").length).toEqual(2)
            expect($ol.find("li")[0].innerHTML).toEqual("1.2")
            expect($ol.find("li")[1].innerHTML).toEqual("1.3")
            expect($ul.children("li").length).toEqual(4)
            expect(clean($($ul.children("li")[1]).html())).toEqual("")

          it "removes the list if there is only 1 item", ->
            $($ol.find("li")[2]).remove()
            $($ol.find("li")[1]).remove()
            handler.handle($ol.find("li").first())
            expect($editable.find("ol").length).toEqual(0)
            expect($ul.find("li").length).toEqual(4)

        describe "middle item", ->
          beforeEach ->
            handler.handle($ol.find("li")[1])

          it "splits the list in two", ->
            expect($editable.find("ol").length).toEqual(2)
            expect($editable.find("ol").first().find("li").length).toEqual(1)
            expect($editable.find("ol").first().find("li").html()).toEqual("1.1")
            expect($editable.find("ol").last().find("li").length).toEqual(1)
            expect($editable.find("ol").last().find("li").html()).toEqual("1.3")

          it "moves the item to the parent list in between the two lists", ->
            $children = $ul.children()
            expect($($children[1]).tagName()).toEqual("ol")
            expect($($children[2]).tagName()).toEqual("li")
            expect(clean($($children[2]).html())).toEqual("")
            expect($($children[3]).tagName()).toEqual("ol")

        describe "last item", ->
          it "moves the item to the parent list", ->
            handler.handle($ol.find("li").last())
            expect($editable.find("ol").find("li").length).toEqual(2)
            expect($ul.children("li").length).toEqual(4)
            expect(clean($($ul.children()[2]).html())).toEqual("")

          it "removes the list if there is only 1 item", ->
            $($ol.find("li")[2]).remove()
            $($ol.find("li")[1]).remove()
            handler.handle($ol.find("li").first())
            expect($editable.find("ol").length).toEqual(0)
            expect($ul.children("li").length).toEqual(4)
            expect(clean($($ul.children()[1]).html())).toEqual("")

    describe "#handlePrevItems", ->
      it "does nothing when there are no previous items", ->
        spyOn($ul, "clone")
        handler.handlePrevItems([], $ul)
        expect($ul.clone).not.toHaveBeenCalled()

      it "places the previous items in a new list before the current list", ->
        handler.handlePrevItems($ul.find("li"), $ul)
        $uls = $editable.find("ul")
        expect($uls.length).toEqual(2)
        expect($uls.first().find("li").length).toEqual(3)
        expect($uls.last().find("li").length).toEqual(0)

    describe "#handleItem", ->
      describe "top-level list", ->
        beforeEach ->
          handler.handleItem($ul.find("li").first(), $ul)

        it "removes the item", ->
          expect($ul.find("li").length).toEqual(2)
          expect($ul.find("li").first().html()).toEqual("2")

        it "adds the next block before the list", ->
          expect($editable.children().first().tagName()).toEqual("p")

        it "puts the selection at the end of the next block", ->
          range = new Range($editable[0], window)
          range.paste("<b></b>")
          expect(clean($editable.find("p").html())).toEqual("<b></b>")

      describe "nested list", ->
        $ul = $ol = null
        beforeEach ->
          $editable.html("
            <ul>
              <li>1</li>
              <ol>
                <li>1.1</li>
                <li>1.2</li>
                <li>1.3</li>
              </ol>
              <li>2</li>
              <li>3</li>
            </ul>
          ")
          $ul = $editable.find("ul")
          $ol = $editable.find("ol")
          handler.handleItem($ol.find("li").first(), $ol)

        it "moves the item before the list", ->
          expect($ol.find("li").length).toEqual(2)
          expect($ol.find("li")[0].innerHTML).toEqual("1.2")
          expect(clean($($ul.children()[1]).html())).toEqual("")
          expect($($ul.children()[2]).tagName()).toEqual("ol")

        it "puts the selection at the end of the item", ->
          range = new Range($editable[0], window)
          range.paste("<b></b>")
          expect(clean($($ul.find("li")[1]).html())).toEqual("<b></b>")

    describe "#handleNextItems", ->
      it "does nothing when there are next items", ->
        spyOn($ul, "remove")
        handler.handleNextItems($ul.find("li"), $ul)
        expect($ul.remove).not.toHaveBeenCalled()

      it "removes the current list when there are no next items", ->
        handler.handleNextItems([], $ul)
        expect($editable.find("ul").length).toEqual(0)

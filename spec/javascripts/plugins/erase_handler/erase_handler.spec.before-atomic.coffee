# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
if isWebkit
  require ["jquery.custom", "plugins/erase_handler/erase_handler", "core/range", "core/helpers"], ($, Handler, Range, Helpers) ->
    describe "EraseHandler", ->
      $editable = $h1 = $p = handler = null
      beforeEach ->
        $editable = addEditableFixture()
        $h1 = $("<h1>header heading</h1>").appendTo($editable)
        $p = $("<p>some text</p>").appendTo($editable)
        handler = new Handler()
        handler.api =
          el: $editable[0]
          getRange: (el) -> new Range($editable[0], el or window)
          select: (el) -> @getRange(el).select()
        Helpers.delegate(handler.api, "getRange()", "delete", "keepRange", "collapse")

      afterEach ->
        $editable.remove()

      describe "#handleCursor", ->
        describe "delete", ->
          event = null
          beforeEach ->
            event = which:46, type: "keydown", preventDefault: ->

          it "merges the nodes together", ->
            range = new Range($editable[0])
            range.range.selectNodeContents($h1[0])
            range.collapse(false)
            range.select()

            handler.handleCursor(event)
            expect($editable.html()).toEqual("<h1>header headingsome text</h1>")

            range = new Range($editable[0], window)
            range.insert("<b></b>")
            expect($h1.html()).toEqual("header heading<b></b>some text")

          it "does not merge the nodes together when the next node is a table", ->
            $("<table><tbody><tr><td>text</td></tr></tbody</table>").insertAfter($h1)
            html = $editable.html()

            range = new Range($editable[0])
            range.range.selectNodeContents($h1[0])
            range.collapse(false)
            range.select()

            handler.handleCursor(event)
            expect($editable.html()).toEqual(html)

            range = new Range($editable[0], window)
            range.insert("<b></b>")
            expect($h1.html()).toEqual("header heading<b></b>")

          it "merges the first list item into the node when the next node is a list", ->
            $ul = $("<ul><li>item</li></ul>").insertAfter($h1)

            range = new Range($editable[0])
            range.range.selectNodeContents($h1[0])
            range.collapse(false)
            range.select()

            handler.handleCursor(event)
            expect($h1.html()).toEqual("header headingitem")
            expect($editable.find("ul").length).toEqual(0)

            range = new Range($editable[0], window)
            range.insert("<b></b>")
            expect($h1.html()).toEqual("header heading<b></b>item")

        describe "backspace", ->
          event = null
          beforeEach ->
            event = which: 8, type: "keydown", preventDefault: ->

          it "merges the nodes together", ->
            range = new Range($editable[0])
            range.range.selectNodeContents($p[0])
            range.collapse(true)
            range.select()

            handler.handleCursor(event)
            expect($editable.html()).toEqual("<h1>header headingsome text</h1>")

            range = new Range($editable[0], window)
            range.insert("<b></b>")
            expect($h1.html()).toEqual("header heading<b></b>some text")

          it "does not merge the nodes together when the previous node is a table", ->
            $("<table><tbody><tr><td>text</td></tr></tbody</table>").insertBefore($p)
            html = $editable.html()

            range = new Range($editable[0])
            range.range.selectNodeContents($p[0])
            range.collapse(true)
            range.select()

            handler.handleCursor(event)
            expect($editable.html()).toEqual(html)

            range = new Range($editable[0], window)
            range.insert("<b></b>")
            expect($p.html()).toEqual("<b></b>some text")

          it "does not merge the nodes together when the previous node is a list", ->
            $ul = $("<ul><li>item</li></ul>").insertBefore($p)
            $li = $ul.find("li")

            range = new Range($editable[0])
            range.range.selectNodeContents($p[0])
            range.collapse(true)
            range.select()

            handler.handleCursor(event)
            expect($li.html()).toEqual("itemsome text")
            expect($editable.find("p").length).toEqual(0)

            range = new Range($editable[0], window)
            range.insert("<b></b>")
            expect($li.html()).toEqual("item<b></b>some text")

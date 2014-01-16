# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
require ["jquery.custom", "plugins/enter_handler/enter_handler", "core/helpers", "core/range"], ($, Handler, Helpers, Range) ->
  describe "EnterHandler", ->
    $editable = null
    beforeEach ->
      $editable = addEditableFixture()
      Handler.api = $.extend($("<div/>"),
        el: $editable[0]
        getRange: (el) -> new Range($editable[0], el or window)
      )
      Helpers.delegate(Handler.api, "getRange()", "getParentElement", "insert", "isEndOfElement", "keepRange", "selectEndOfElement")

    afterEach ->
      $editable.remove()

    describe "#handleBR", ->
      range = $div = null
      beforeEach ->
        $editable.html("<div>enter</div><p>after</p>")
        $div = $editable.find("div")
        range = new Range($editable[0])

      it "adds a <br> after the node", ->
        if hasW3CRanges
          range.range.setEnd($div[0].childNodes[0], 4)
        else
          range.range.findText("ente")
        range.collapse(false).select()

        Handler.handleBR($("<br/>")[0])
        expect(clean($div.html())).toEqual("ente<br>r")

      it "places the caret after the <br> when there is text after", ->
        if hasW3CRanges
          range.range.setEnd($div[0].childNodes[0], 4)
        else
          range.range.findText("ente")
        range.collapse(false).select()

        Handler.handleBR($("<br/>")[0])
        range = new Range($editable[0], window)
        range.insert("<b></b>")
        expect(clean($div.html())).toEqual("ente<br><b></b>r")

      it "places the caret after the <br> when there is no text after", ->
        if hasW3CRanges
          range.range.setEnd($div[0].childNodes[0], 5)
        else
          range.range.findText("enter")
        range.collapse(false).select()

        Handler.handleBR($("<br/>")[0])
        range = new Range($editable[0], window)
        range.insert("<b></b>")
        expect(clean($div.html())).toEqual("enter<br><b></b>")

    describe "#handleNewline", ->
      range = $pre = null
      beforeEach ->
        $editable.html("<pre>abc\ndef\nghi</pre>")
        $pre = $editable.find("pre")
        range = new Range($editable[0])

      it "adds a newline at the beginning of line", ->
        if hasW3CRanges
          # IE11 (possibly other versions) needs the setStart when its the
          # first position only
          range.range.setStart($pre[0].childNodes[0], 0)
          range.range.setEnd($pre[0].childNodes[0], 0)
        else
          range.range.findText("a")
        range.collapse(true).select()
        expect($editable.text()).not.toMatch("\nabc")
        Handler.handleNewline()
        expect($editable.text()).toMatch("\nabc")

      it "adds a newline in middle of line", ->
        if hasW3CRanges
          range.range.setEnd($pre[0].childNodes[0], 1)
        else
          range.range.findText("a")
        range.collapse(false).select()
        expect($editable.text()).not.toMatch("a\nbc")
        Handler.handleNewline()
        expect($editable.text()).toMatch("a\nbc")

      it "adds a newline at the end of a line", ->
        if hasW3CRanges
          range.range.setEnd($pre[0].childNodes[0], 3)
        else
          range.range.findText("abc")
        range.collapse(false).select()
        if !isIE8
          expect($editable.text()).not.toMatch("abc\n\ndef")
        else
          expect($editable.html()).not.toMatch("abc\r?\n\r?\ndef")
          
        Handler.handleNewline()
        if !isIE8
          expect($editable.text()).toMatch("abc\n\ndef")
        else
          expect($editable.html()).toMatch("abc\r?\n\r?\ndef")

      it "adds a newline at the very end", ->
        if hasW3CRanges
          range.range.setEnd($pre[0].childNodes[0], 11)
        else
          range.range.findText("ghi")
        range.collapse(false).select()
        if !isIE8
          expect($editable.text()).not.toMatch("ghi\n")
        else
          expect($editable.html()).not.toMatch("ghi\r?\n")
        Handler.handleNewline()
        if !isIE8
          expect($editable.text()).toMatch("ghi\n")
        else
          expect($editable.html()).toMatch("ghi\r?\n")



    describe "#handleBlock", ->
      range = $div = null
      beforeEach ->
        $editable.html("<div>enter</div><p>after</p>")
        $div = $editable.find("div")
        range = new Range($editable[0])

      describe "end of block", ->
        beforeEach ->
          if hasW3CRanges
            range.range.setEnd($div[0].childNodes[0], 5)
          else
            range.range.findText("enter")
          range.collapse(false).select()

        it "adds the next element", ->
          $p = $("<p/>")
          Handler.handleBlock($div[0], $p[0])
          expect($editable.children()[0]).toBe($div[0])
          expect($editable.children()[1]).toBe($p[0])

        it "places the caret at the beginning of the next element", ->
          $p = $("<p/>")
          Handler.handleBlock($div[0], $p[0])
          range = new Range($editable[0], window)
          range.insert("<b></b>")
          expect(clean($p.html())).toEqual("<b></b>")

      describe "not end of block", ->
        beforeEach ->
          if hasW3CRanges
            range.range.setEnd($div[0].childNodes[0], 3)
          else
            range.range.findText("ent")
          range.collapse(false).select()

        it "splits the block", ->
          Handler.handleBlock($div[0])
          expect(clean($editable.children()[0].innerHTML)).toEqual("ent")
          expect(clean($editable.children()[1].innerHTML)).toEqual("er")

        it "places the caret at the beginning of the second element", ->
          Handler.handleBlock($div[0])
          range = new Range($editable[0], window)
          range.insert("<b></b>")
          expect(clean($editable.children()[1].innerHTML)).toEqual("<b></b>er")

      describe "beginning of block", ->
        beforeEach ->
          if hasW3CRanges
            range.range.setStart($div[0].childNodes[0], 0)
          else
            range.range.findText("ent")
          range.collapse(true).select()

        it "splits the block and places a <br> in the first block", ->
          Handler.handleBlock($div[0])
          expect(clean($editable.children()[0].innerHTML)).toEqual("&nbsp;")
          expect(clean($editable.children()[1].innerHTML)).toEqual("enter")

        it "places the caret at the beginning of the second element", ->
          Handler.handleBlock($div[0])
          range = new Range($editable[0], window)
          range.insert("<b></b>")
          expect(clean($editable.children()[1].innerHTML)).toEqual("<b></b>enter")

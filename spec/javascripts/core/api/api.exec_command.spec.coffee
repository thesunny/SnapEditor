 require ["jquery.custom", "core/api/api.exec_command", "core/range", "core/helpers"], ($, ExecCommand, Range, Helpers) ->
  describe "API.ExecCommand", ->
    $editable = execCommand = null
    beforeEach ->
      $editable = addEditableFixture()
      execCommand = new ExecCommand()
      execCommand.api =
        doc: document
        win: window
        el: $editable[0]
        find: (selector) -> $(@doc).find(selector)
        range: -> new Range($editable[0], window)
        blankRange: -> new Range($editable[0])
        isValid: -> true
      Helpers.delegate(execCommand.api, "range()", "getParentElement", "getParentElements", "isCollapsed", "unselect", "paste")
      Helpers.delegate(execCommand.api, "blankRange()", "select", "selectNodeContents", "selectEndOfElement")

    afterEach ->
      $editable.remove()

    describe "#formatInline", ->
      it "throws an error when the tag is not supported", ->
        spyOn(execCommand, "exec")
        expect(-> execCommand.formatInline("test")).toThrow()

      it "bolds given 'b'", ->
        $div = $("<div>some text</div>").appendTo($editable)
        new Range($editable[0], $div[0]).select()
        execCommand.formatInline("b")
        if isIE
          expect(clean($div.html())).toEqual("<strong>some text</strong>")
        else
          expect($div.html()).toEqual("<b>some text</b>")

      it "italicizes given 'i'", ->
        $div = $("<div>some text</div>").appendTo($editable)
        new Range($editable[0], $div[0]).select()
        execCommand.formatInline("i")
        if isIE
          expect(clean($div.html())).toEqual("<em>some text</em>")
        else
          expect($div.html()).toEqual("<i>some text</i>")

      if isGecko
        it "styles without CSS in Gecko", ->
          spyOn(execCommand, "exec")
          execCommand.formatInline("b")
          expect(execCommand.exec.argsForCall[0]).toEqual(["styleWithCSS", false])

    describe "#insertLink", ->
      $link = range = $div = insertedLinks = $a = null
      beforeEach ->
        $link = $('<a href="http://snapeditor.com/test" target="_blank"></a>')

      describe "caret in text", ->
        beforeEach ->
          $div = $("<div>some text</div>").appendTo($editable)
          range = new Range($editable[0])
          if hasW3CRanges
            range.range.setEnd($div[0].childNodes[0], 4)
          else
            range.range.findText("some")
          range.collapse(false).select()
          insertedLinks = execCommand.insertLink($link[0])
          $a = $div.find("a")

        it "inserts the link", ->
          expect(clean($div.html())).toEqual("some<a href=http://snapeditor.com/test target=_blank>http://snapeditor.com/test</a> text")

        it "returns the inserted links", ->
          expect(insertedLinks.length).toEqual(1)
          expect(insertedLinks[0]).toBe($a[0])

        #it "places the selection at the end of the last link", ->
          #range = new Range($editable[0], window)
          #expect(range.getParentElement()).toBe($a[0])

      describe "caret in link", ->
        beforeEach ->
          $div = $('<div>some <a href="http://snapeditor.com/exists">link</a> text</div>').appendTo($editable)
          range = new Range($editable[0])
          if hasW3CRanges
            range.range.setStart($div.find("a")[0].childNodes[0], 1)
          else
            range.range.findText("ink")
          range.collapse(true).select()
          insertedLinks = execCommand.insertLink($link[0])
          $a = $div.find("a")

        it "modifies the link", ->
          expect(clean($div.html())).toEqual("some <a href=http://snapeditor.com/test target=_blank>link</a> text")

        it "returns the inserted links", ->
          expect(insertedLinks.length).toEqual(1)
          expect(insertedLinks[0]).toBe($a[0])

        #it "places the selection at the end of the last link", ->
          #range = new Range($editable[0], window)
          #expect(range.getParentElement()).toBe($a[0])

      describe "selecting text only", ->
        beforeEach ->
          $div = $("<div>some text</div>").appendTo($editable)
          range = new Range($editable[0])
          if hasW3CRanges
            range.range.setStart($div[0].childNodes[0], 0)
            range.range.setEnd($div[0].childNodes[0], 4)
          else
            range.range.findText("some")
          range.select()
          insertedLinks = execCommand.insertLink($link[0])
          $a = $div.find("a")

        it "inserts the link", ->
          expect(clean($div.html())).toEqual("<a href=http://snapeditor.com/test target=_blank>some</a> text")

        it "returns the inserted links", ->
          expect(insertedLinks.length).toEqual(1)
          expect(insertedLinks[0]).toBe($a[0])

        #it "places the selection at the end of the last link", ->
          #range = new Range($editable[0], window)
          #expect(range.getParentElement()).toBe($a[0])

      describe "selecting across inline elements", ->
        $div = insertedLinks = $a = null
        beforeEach ->
          $div = $("<div>some <b>text <i>with</i> elements</b> in it</div>").appendTo($editable)
          range = new Range($editable[0])
          if hasW3CRanges
            range.range.setStart($div[0].childNodes[0], 2)
            range.range.setEnd($div[0].childNodes[1].childNodes[2], 5)
          else
            range.range.findText("me text with elem")
          range.select()
          insertedLinks = execCommand.insertLink($link[0])
          $a = $div.find("a")

        it "inserts the link", ->
          expect(clean($div.html())).toEqual("so<a href=http://snapeditor.com/test target=_blank>me </a><b><a href=http://snapeditor.com/test target=_blank>text <i>with</i> elem</a>ents</b> in it")

        it "returns the inserted links", ->
          expect(insertedLinks.length).toEqual(2)
          expect(insertedLinks[0]).toBe($a[0])
          expect(insertedLinks[1]).toBe($a[1])

        #it "places the selection at the end of the last link", ->
          #range = new Range($editable[0], window)
          #expect(range.getParentElement()).toBe($a[1])

      describe "selecting across block elements", ->
        $start = $end = null
        beforeEach ->
          $start = $("<div>start text</div>").appendTo($editable)
          $end = $("<div>end text</div>").appendTo($editable)
          range = new Range($editable[0])
          if hasW3CRanges
            range.range.setStart($start[0].childNodes[0], 2)
            range.range.setEnd($end[0].childNodes[0], 7)
          else
            range.range.findText("art text")
            endRange = new Range($editable[0])
            endRange.range.findText("end tex")
            range.range.setEndPoint("EndToEnd", endRange.range)
          range.select()
          insertedLinks = execCommand.insertLink($link[0])
          $a = $editable.find("a")

        it "inserts the link", ->
          expect(clean($editable.html())).toEqual("<div>st<a href=http://snapeditor.com/test target=_blank>art text</a></div><div><a href=http://snapeditor.com/test target=_blank>end tex</a>t</div>")

        it "returns the inserted links", ->
          expect(insertedLinks.length).toEqual(2)
          expect(insertedLinks[0]).toBe($a[0])
          expect(insertedLinks[1]).toBe($a[1])

        #it "places the selection at the end of the last link", ->
          #range = new Range($editable[0], window)
          #expect(range.getParentElement()).toBe($a[1])

      describe "image", ->
        $img = null
        beforeEach ->
          $editable.html("<img src=\"http://#{document.location.host}/spec/javascripts/support/assets/images/stub.png\" />")
          $img = $editable.find("img")
          range = new Range($editable[0], $img[0])
          range.select()
          insertedLinks = execCommand.insertLink($link[0])
          $a = $editable.find("a")

        it "inserts the link", ->
          expect(clean($editable.html())).toEqual("<a href=http://snapeditor.com/test target=_blank><img src=http://#{document.location.host}/spec/javascripts/support/assets/images/stub.png></a>")

        it "returns the inserted links", ->
          expect(insertedLinks.length).toEqual(1)
          expect(insertedLinks[0]).toBe($a[0])

        #it "places the selection at the end of the last link", ->
          #range = new Range($editable[0], window)
          #expect(range.getParentElement()).toBe($a[0])

      describe "link", ->
        $existingLink = null
        beforeEach ->
          $editable.html('<a href="http://snapeditor.com/exist">exist</a>')
          $existingLink = $editable.find("a")
          range = new Range($editable[0], $existingLink[0])
          range.select()
          insertedLinks = execCommand.insertLink($link[0])
          $a = $editable.find("a")

        it "modifies the existing link", ->
          expect(clean($editable.html())).toEqual("<a href=http://snapeditor.com/test target=_blank>exist</a>")

        it "returns the inserted links", ->
          expect(insertedLinks.length).toEqual(1)
          expect(insertedLinks[0]).toBe($a[0])

        #it "places the selection at the end of the last link", ->
          #range = new Range($editable[0], window)
          #expect(range.getParentElement()).toBe($a[0])

      describe "partial link", ->
        $existingLink = null
        beforeEach ->
          $editable.html('before <a href="http://snapeditor.com/exist">exist</a> after')
          $existingLink = $editable.find("a")
          range = new Range($editable[0])
          if hasW3CRanges
            range.range.setStart($existingLink[0].childNodes[0], 3)
            range.range.setEnd($editable[0].childNodes[2], 3)
          else
            range.range.findText("st aft")
          range.select()

        it "modifies the link when the selection starts inside a link", ->
          insertedLinks = execCommand.insertLink($link[0])
          $a = $editable.find("a")
          expect(clean($editable.html())).toEqual("before <a href=http://snapeditor.com/test target=_blank>exist</a> after")

        it "modifies the link when the selection ends inside a link", ->
          if hasW3CRanges
            range.range.setStart($editable[0].childNodes[0], 3)
            range.range.setEnd($existingLink[0].childNodes[0], 3)
          else
            range.range.findText("ore exi")
          range.select()
          insertedLinks = execCommand.insertLink($link[0])
          $a = $editable.find("a")
          expect(clean($editable.html())).toEqual("before <a href=http://snapeditor.com/test target=_blank>exist</a> after")

        it "returns the inserted links", ->
          insertedLinks = execCommand.insertLink($link[0])
          $a = $editable.find("a")
          expect(insertedLinks.length).toEqual(1)
          expect(insertedLinks[0]).toBe($a[0])

        #it "places the selection at the end of the last link", ->
          #insertedLinks = execCommand.insertLink($link[0])
          #$a = $editable.find("a")
          #range = new Range($editable[0], window)
          #expect(range.getParentElement()).toBe($a[0])

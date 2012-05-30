 require ["plugins/styler/styler.inline", "core/range", "core/helpers"], (Styler, Range, Helpers) ->
  describe "Styler.Inline", ->
    $editable = styler = null
    beforeEach ->
      $editable = addEditableFixture()
      styler = new Styler()
      styler.api =
        update: ->
        clean: ->
        range: -> new Range($editable[0], window)
      Helpers.delegate(styler.api, "range()", "isValid", "isCollapsed", "getParentElement", "paste", "surroundContents")

    afterEach ->
      $editable.remove()

    describe "#bold", ->
      it "bolds the selection", ->
        $div = $("<div>some text</div>").appendTo($editable)
        new Range($editable[0], $div[0]).select()
        styler.bold()
        if isIE
          expect(clean($div.html())).toEqual("<strong>some text</strong>")
        else
          expect($div.html()).toEqual("<b>some text</b>")

    describe "#italic", ->
      it "italicizes the selection", ->
        $div = $("<div>some text</div>").appendTo($editable)

        new Range($editable[0], $div[0]).select()
        styler.italic()
        if isIE
          expect(clean($div.html())).toEqual("<em>some text</em>")
        else
          expect($div.html()).toEqual("<i>some text</i>")

    describe "#format", ->
      it "throws an error when the tag is not supported", ->
        spyOn(document, "execCommand")
        spyOn(styler, "update")
        expect(-> styler.format("test")).toThrow()

      it "bolds given 'b'", ->
        spyOn(document, "execCommand")
        spyOn(styler, "exec")
        spyOn(styler, "update")
        styler.format("b")
        expect(styler.exec).toHaveBeenCalledWith("bold")

      it "italicizes given 'i'", ->
        spyOn(document, "execCommand")
        spyOn(styler, "exec")
        spyOn(styler, "update")
        styler.format("i")
        expect(styler.exec).toHaveBeenCalledWith("italic")

      it "updates the api", ->
        spyOn(document, "execCommand")
        spyOn(styler, "exec")
        spyOn(styler, "update")
        styler.format("b")
        expect(styler.update).toHaveBeenCalled()

      if isGecko
        it "styles without CSS in Gecko", ->
          spyOn(document, "execCommand")
          styler.format("b")
          expect(document.execCommand).toHaveBeenCalledWith("styleWithCSS", false, false)

    describe "#link", ->
      api = null
      beforeEach ->
        spyOn(window, "prompt").andReturn("http://snapeditor.com")

      it "does not do anything if nothing is entered", ->
        window.prompt.andReturn(null)
        spyOn(styler, "update")
        styler.link()
        expect(styler.update).not.toHaveBeenCalled()

      it "changes the href if a link is selected", ->
        $a = $('<a href="http://example.com">some text</a>').appendTo($editable)
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($a[0].childNodes[0], 5)
        else
          range.range.findText("text")
          range.collapse(true)
        range.select()

        spyOn(styler, "update")
        styler.link()
        expect($a.attr("href")).toEqual("http://snapeditor.com")

      it "adds a link if the range is collapsed", ->
        $div = $("<div>some text</div>").appendTo($editable)

        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($div[0].childNodes[0], 5)
        else
          range.range.findText("text")
        range.collapse(true)
        range.select()

        spyOn(styler, "update")
        styler.link()
        if isIE7
          expect(clean($div.html())).toEqual('some <a href=http://snapeditor.com/>http://snapeditor.com</a>text')
        else
          expect(clean($div.html())).toEqual('some <a href=http://snapeditor.com>http://snapeditor.com</a>text')

      it "surrounds the content with a link", ->
        $div = $("<div>some text</div>").appendTo($editable)
        $span = $div.find("span")
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($div[0].childNodes[0], 5)
          range.range.setEnd($div[0].childNodes[0], 9)
        else
          range.range.findText("text")
        range.select()

        spyOn(styler, "update")
        styler.link()
        if isIE7
          expect(clean($div.html())).toEqual('some <a href=http://snapeditor.com/>text</a>')
        else
          expect(clean($div.html())).toEqual('some <a href=http://snapeditor.com>text</a>')

      it "updates the api", ->
        $a = $('<a href="http://example.com">some text</a>').appendTo($editable)
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($a[0].childNodes[0], 5)
        else
          range.range.findText("text")
          range.collapse(true)
        range.select()

        spyOn(styler, "update")
        styler.link()
        expect(styler.update).toHaveBeenCalled()

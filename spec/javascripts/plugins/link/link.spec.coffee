 require ["plugins/link/link", "core/range", "core/helpers"], (Link, Range, Helpers) ->
  describe "Link", ->
    $editable = link = null
    beforeEach ->
      $editable = addEditableFixture()
      link = new Link()
      link.api =
        update: ->
        clean: ->
        range: -> new Range($editable[0], window)
        isValid: -> true
      Helpers.delegate(link.api, "range()", "isCollapsed", "getParentElement", "paste", "surroundContents")

    afterEach ->
      $editable.remove()

    describe "#link", ->
      api = null
      beforeEach ->
        spyOn(window, "prompt").andReturn("http://snapeditor.com")

      it "does not do anything if nothing is entered", ->
        window.prompt.andReturn(null)
        spyOn(link, "update")
        link.link()
        expect(link.update).not.toHaveBeenCalled()

      it "changes the href if a link is selected", ->
        $a = $('<a href="http://example.com">some text</a>').appendTo($editable)
        range = new Range($editable[0])
        if hasW3CRanges
          range.range.setStart($a[0].childNodes[0], 5)
        else
          range.range.findText("text")
          range.collapse(true)
        range.select()

        spyOn(link, "update")
        link.link()
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

        spyOn(link, "update")
        link.link()
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

        spyOn(link, "update")
        link.link()
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

        spyOn(link, "update")
        link.link()
        expect(link.update).toHaveBeenCalled()

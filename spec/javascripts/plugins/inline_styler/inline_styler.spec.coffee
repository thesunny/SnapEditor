describe "InlineStyler", ->
  required = ["cs!plugins/inline_styler/inline_styler", "cs!core/range"]

  describe "bold", ->
    ait "bolds the selection", required, (InlineStyler, Range) ->
      $editable = addEditableFixture()
      $div = $("<div>some text</div>").appendTo($editable)

      new Range($editable[0], $div[0]).select()
      styler = new InlineStyler()
      styler.api = { update: -> }
      styler.bold()
      if isIE
        # NOTE: IE returns tags as uppercase, hence th use of toLowerCase()
        expect($div.html().toLowerCase()).toEqual("<strong>some text</strong>")
      else
        expect($div.html()).toEqual("<b>some text</b>")

      $editable.remove()

  describe "italic", ->
    ait "italicizes the selection", required, (InlineStyler, Range) ->
      $editable = addEditableFixture()
      $div = $("<div>some text</div>").appendTo($editable)

      new Range($editable[0], $div[0]).select()
      styler = new InlineStyler()
      styler.api = { update: -> }
      styler.italic()
      if isIE
        # NOTE: IE returns tags as uppercase, hence th use of toLowerCase()
        expect($div.html().toLowerCase()).toEqual("<em>some text</em>")
      else
        expect($div.html()).toEqual("<i>some text</i>")

      $editable.remove()

  describe "#format", ->
    ait "throws an error when the tag is not supported", required, (InlineStyler, Range) ->
      spyOn(document, "execCommand")
      styler = new InlineStyler()
      styler.api = { update: -> }
      expect(-> styler.format("test")).toThrow()

    ait "bolds given 'b'", required, (InlineStyler, Range) ->
      spyOn(document, "execCommand")
      styler = new InlineStyler()
      styler.api = { update: -> }
      spyOn(styler, "exec")
      styler.format("b")
      expect(styler.exec).toHaveBeenCalledWith("bold")

    ait "italicizes given 'i'", required, (InlineStyler, Range) ->
      spyOn(document, "execCommand")
      styler = new InlineStyler()
      styler.api = { update: -> }
      spyOn(styler, "exec")
      styler.format("i")
      expect(styler.exec).toHaveBeenCalledWith("italic")

    ait "updates the api", required, (InlineStyler, Range) ->
      spyOn(document, "execCommand")
      api = { update: null }
      spyOn(api, "update")

      styler = new InlineStyler()
      styler.api = api
      spyOn(styler, "exec")
      styler.format("b")
      expect(api.update).toHaveBeenCalled()

    if isGecko
      ait "styles without CSS in Gecko", required, (InlineStyler, Range) ->
        spyOn(document, "execCommand")
        styler = new InlineStyler()
        styler.api = { update: -> }
        styler.format("b")
        expect(document.execCommand).toHaveBeenCalledWith("styleWithCSS", false, false)

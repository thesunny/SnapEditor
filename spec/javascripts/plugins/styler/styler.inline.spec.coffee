 require ["plugins/styler/styler.inline", "core/range"], (Styler, Range) ->
  describe "Styler.Inline", ->
    $editable = null
    beforeEach ->
      $editable = addEditableFixture()

    afterEach ->
      $editable.remove()

    describe "#bold", ->
      it "bolds the selection", ->
        $div = $("<div>some text</div>").appendTo($editable)
        new Range($editable[0], $div[0]).select()
        styler = new Styler()
        styler.api = { update: -> }
        styler.bold()
        if isIE
          # NOTE: IE returns tags as uppercase, hence th use of toLowerCase()
          expect($div.html().toLowerCase()).toEqual("<strong>some text</strong>")
        else
          expect($div.html()).toEqual("<b>some text</b>")

    describe "#italic", ->
      it "italicizes the selection", ->
        $editable = addEditableFixture()
        $div = $("<div>some text</div>").appendTo($editable)

        new Range($editable[0], $div[0]).select()
        styler = new Styler()
        styler.api = { update: -> }
        styler.italic()
        if isIE
          # NOTE: IE returns tags as uppercase, hence th use of toLowerCase()
          expect($div.html().toLowerCase()).toEqual("<em>some text</em>")
        else
          expect($div.html()).toEqual("<i>some text</i>")

        $editable.remove()

    describe "#format", ->
      it "throws an error when the tag is not supported", ->
        spyOn(document, "execCommand")
        styler = new Styler()
        spyOn(styler, "update")
        expect(-> styler.format("test")).toThrow()

      it "bolds given 'b'", ->
        spyOn(document, "execCommand")
        styler = new Styler()
        spyOn(styler, "exec")
        spyOn(styler, "update")
        styler.format("b")
        expect(styler.exec).toHaveBeenCalledWith("bold")

      it "italicizes given 'i'", ->
        spyOn(document, "execCommand")
        styler = new Styler()
        spyOn(styler, "exec")
        spyOn(styler, "update")
        styler.format("i")
        expect(styler.exec).toHaveBeenCalledWith("italic")

      it "updates the api", ->
        spyOn(document, "execCommand")
        styler = new Styler()
        spyOn(styler, "exec")
        spyOn(styler, "update")
        styler.format("b")
        expect(styler.update).toHaveBeenCalled()

      if isGecko
        it "styles without CSS in Gecko", ->
          spyOn(document, "execCommand")
          styler = new Styler()
          styler.api = { update: -> }
          styler.format("b")
          expect(document.execCommand).toHaveBeenCalledWith("styleWithCSS", false, false)

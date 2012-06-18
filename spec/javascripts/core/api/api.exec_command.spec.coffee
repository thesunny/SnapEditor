 require ["core/api/api.exec_command", "core/range", "core/helpers"], (ExecCommand, Range, Helpers) ->
  describe "API.ExecCommand", ->
    $editable = execCommand = null
    beforeEach ->
      $editable = addEditableFixture()
      execCommand = new ExecCommand()
      execCommand.api =
        range: -> new Range($editable[0], window)
        isValid: -> true
      Helpers.delegate(execCommand.api, "range()", "getParentElement")

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

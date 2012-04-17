describe "Styler.Inline", ->
  required = ["cs!plugins/styler/styler.inline", "cs!core/range"]

  $editable = null
  beforeEach ->
    $editable = addEditableFixture()

  afterEach ->
    $editable.remove()

  describe "#bold", ->
    ait "bolds the selection", required, (Styler, Range) ->
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
    ait "italicizes the selection", required, (Styler, Range) ->
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
    ait "throws an error when the tag is not supported", required, (Styler, Range) ->
      spyOn(document, "execCommand")
      styler = new Styler()
      spyOn(styler, "update")
      expect(-> styler.format("test")).toThrow()

    ait "bolds given 'b'", required, (Styler, Range) ->
      spyOn(document, "execCommand")
      styler = new Styler()
      spyOn(styler, "exec")
      spyOn(styler, "update")
      styler.format("b")
      expect(styler.exec).toHaveBeenCalledWith("bold")

    ait "italicizes given 'i'", required, (Styler, Range) ->
      spyOn(document, "execCommand")
      styler = new Styler()
      spyOn(styler, "exec")
      spyOn(styler, "update")
      styler.format("i")
      expect(styler.exec).toHaveBeenCalledWith("italic")

    ait "updates the api", required, (Styler, Range) ->
      spyOn(document, "execCommand")
      styler = new Styler()
      spyOn(styler, "exec")
      spyOn(styler, "update")
      styler.format("b")
      expect(styler.update).toHaveBeenCalled()

    if isGecko
      ait "styles without CSS in Gecko", required, (Styler, Range) ->
        spyOn(document, "execCommand")
        styler = new Styler()
        styler.api = { update: -> }
        styler.format("b")
        expect(document.execCommand).toHaveBeenCalledWith("styleWithCSS", false, false)

  describe "#link", ->
    API = null
    beforeEach ->
      spyOn(window, "prompt").andReturn("http://snapeditor.com")
      class API
        constructor: (@Range) ->
        range: -> new @Range($editable[0], window)
        isCollapsed: -> @range().isCollapsed()
        getParentElement: (match) -> @range().getParentElement(match)
        paste: (arg) -> @range().paste(arg)
        surroundContents: (el) -> @range().surroundContents(el)

    ait "does not do anything if nothing is entered", required, (Styler, Range) ->
      window.prompt.andReturn(null)
      styler = new Styler()
      spyOn(styler, "update")
      styler.link()
      expect(styler.update).not.toHaveBeenCalled()

    ait "changes the href if a link is selected", required, (Styler, Range) ->
      $a = $('<a href="http://example.com">some text</a>').appendTo($editable)
      range = new Range($editable[0])
      if hasW3CRanges
        range.range.setStart($a[0].childNodes[0], 5)
      else
        range.range.findText("text")
        range.collapse(true)
      range.select()

      styler = new Styler()
      styler.api = new API(Range)
      spyOn(styler, "update")
      styler.link()
      expect($a.attr("href")).toEqual("http://snapeditor.com")

    ait "adds a link if the range is collapsed", required, (Styler, Range) ->
      $div = $("<div>some text</div>").appendTo($editable)

      range = new Range($editable[0])
      if hasW3CRanges
        range.range.setStart($div[0].childNodes[0], 5)
      else
        range.range.findText("text")
      range.collapse(true)
      range.select()

      styler = new Styler()
      styler.api = new API(Range)
      spyOn(styler, "update")
      styler.link()
      if isIE7
        expect($div.html().toLowerCase()).toEqual('some <a href="http://snapeditor.com/">http://snapeditor.com</a>text')
      else
        expect($div.html().toLowerCase()).toEqual('some <a href="http://snapeditor.com">http://snapeditor.com</a>text')

    ait "surrounds the content with a link", required, (Styler, Range) ->
      $div = $("<div>some text</div>").appendTo($editable)
      $span = $div.find("span")
      range = new Range($editable[0])
      if hasW3CRanges
        range.range.setStart($div[0].childNodes[0], 5)
        range.range.setEnd($div[0].childNodes[0], 9)
      else
        range.range.findText("text")
      range.select()

      styler = new Styler()
      styler.api = new API(Range)
      spyOn(styler, "update")
      styler.link()
      if isIE7
        expect($div.html().toLowerCase()).toEqual('some <a href="http://snapeditor.com/">text</a>')
      else
        expect($div.html().toLowerCase()).toEqual('some <a href="http://snapeditor.com">text</a>')

    ait "updates the api", required, (Styler, Range) ->
      $a = $('<a href="http://example.com">some text</a>').appendTo($editable)
      range = new Range($editable[0])
      if hasW3CRanges
        range.range.setStart($a[0].childNodes[0], 5)
      else
        range.range.findText("text")
        range.collapse(true)
      range.select()

      styler = new Styler()
      styler.api = new API(Range)
      spyOn(styler, "update")
      styler.link()
      expect(styler.update).toHaveBeenCalled()

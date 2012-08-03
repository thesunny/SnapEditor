 require ["jquery.custom", "plugins/link/link", "core/range", "core/helpers"], ($, Link, Range, Helpers) ->
  describe "Link", ->
    $editable = link = null
    beforeEach ->
      $editable = addEditableFixture()
      link = new Link()
      link.api =
        createElement: (name) -> document.createElement(name)
        update: ->
        clean: ->
        range: -> new Range($editable[0], window)
        isValid: -> true
      Helpers.delegate(link.api, "range()", "isCollapsed", "getParentElement", "paste", "surroundContents", "isImageSelected")

    afterEach ->
      $editable.remove()

    #describe "test", ->
      #$div = log = null
      #beforeEach ->
        #$div = $("<div>text</div>").appendTo($editable)
        #log = (type, url) ->
          #p type

          #$a = $("<a id='LINK' href='#{url}'>link</a>")
          #$a.appendTo($editable)
          #$a = $("#LINK")
          #p "DOM insert: #{$a.attr("href")}"
          #$a.remove()

          #$a = $("<a id='LINK' href='#{url}'>link</a>")
          #range = new Range($editable[0])
          #range.selectEndOfElement($div[0])
          #range.paste($a[0])
          #$a = $("#LINK")
          #p "Range paste: #{$a.attr("href")}"
          #$a.remove()

          #$a = $('<a id="LINK">link</a>')
          #$a.appendTo($editable)
          #$a.attr("href", url)
          #$a = $("#LINK")
          #p "DOM modify: #{$a.attr("href")}"
          #$a.remove()

      #it "full URL", ->
        #log("URL", "http://snapeditor.com")
        #log("URL NO PROTOCOL", "//snapeditor.com")
        #log("URL JUST DOMAIN", "snapeditor.com")

      #it "root path", ->
        #log("ROOT PATH", "/abc")

      #it "relative path", ->
        #log("RELATIVE PATH", "123")
        #log("RELATIVE PATH IMAGE", "image.png")

    describe "#normalize", ->
      it "normalizes an email", ->
        expect(link.normalize("wesley@snapeditor.com")).toEqual("mailto:wesley@snapeditor.com")

      it "normalizes a full URL", ->
        expect(link.normalize("http://snapeditor.com")).toEqual("http://snapeditor.com")

      it "normalizes a URL without a protocol", ->
        expect(link.normalize("//snapeditor.com")).toEqual("http://snapeditor.com")

      it "normalizes an absolute path", ->
        expect(link.normalize("/abc")).toEqual("/abc")

      it "normalizes a relative path", ->
        expect(link.normalize("abc")).toEqual("http://abc")

      it "normalizes a domain", ->
        expect(link.normalize("snapeditor.com")).toEqual("http://snapeditor.com")

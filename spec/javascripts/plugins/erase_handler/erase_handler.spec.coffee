if isWebkit
  require ["jquery.custom", "plugins/erase_handler/erase_handler", "core/range", "core/helpers"], ($, Handler, Range, Helpers) ->
    describe "EraseHandler", ->
      $editable = $h1 = $p = handler = null
      beforeEach ->
        $editable = addEditableFixture()
        $h1 = $("<h1>header heading</h1>").appendTo($editable)
        $p = $("<p>some text</p>").appendTo($editable)
        handler = new Handler()
        handler.api = range: (el) -> new Range($editable[0], el or window)
        Helpers.delegate(handler.api, "range()", "delete", "keepRange")

      afterEach ->
        $editable.remove()

      describe "#handleCursor", ->
        it "merges the nodes together when deleting", ->
          range = new Range($editable[0])
          range.range.selectNodeContents($h1[0])
          range.collapse(false)
          range.select()

          handler.handleCursor(which: 46, type: "keydown", preventDefault: ->)
          expect($editable.html()).toEqual("<h1>header headingsome text</h1>")

          range = new Range($editable[0], window)
          range.paste("<b></b>")
          expect($h1.html()).toEqual("header heading<b></b>some text")

        it "merges the nodes together when backspacing", ->
          range = new Range($editable[0])
          range.range.selectNodeContents($p[0])
          range.collapse(true)
          range.select()

          handler.handleCursor(which: 8, type: "keydown", preventDefault: ->)
          expect($editable.html()).toEqual("<h1>header headingsome text</h1>")

          range = new Range($editable[0], window)
          range.paste("<b></b>")
          expect($h1.html()).toEqual("header heading<b></b>some text")

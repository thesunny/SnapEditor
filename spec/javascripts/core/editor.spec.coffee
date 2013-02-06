require ["core/editor", "core/helpers"], (Editor, Helpers) ->
  describe "Editor", ->
    $editable = editor = null
    beforeEach ->
      $editable = addEditableFixture()
      defaults =
        plugins: []
        toolbar: []
        cleaner:
          whitelist:
            "P": "p"
            "*": "P"
          ignore: []
        lang: "en",
        eraseHandler:
          delete: "delete"
        atomic:
          classname: "atomic"
        widget:
          classname: "widget"
      config = path: "spec/javascripts/support/assets"
      editor = new Editor($editable[0], defaults, config)

    afterEach ->
      $editable.remove()

    describe "#constructor", ->
      it "saves the element as a jQuery element", ->
        expect(editor.$el.attr).toBeDefined()

      it "creates an API", ->
        expect(editor.api).not.toBeNull()

    describe "#getContents", ->
      it "returns the contents of the editor", ->
        $editable.html("<p>this is just a test</p><p>yes it is</p>")
        expect(clean(editor.getContents())).toEqual("<p>this is just a test</p><p>yes it is</p>")

      it "removes any zero width no break spaces", ->
        $editable.html("<p>Hello, there #{Helpers.zeroWidthNoBreakSpace}are zero width no #{Helpers.zeroWidthNoBreakSpace}break spaces in#{Helpers.zeroWidthNoBreakSpace} here!")
        expect(editor.getContents().match(Helpers.zeroWidthNoBreakSpaceUnicode)).toBeNull()

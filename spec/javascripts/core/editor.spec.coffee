require ["core/editor"], (Editor) ->
  describe "Editor", ->
    $editable = null
    beforeEach ->
      $editable = addEditableFixture()

    afterEach ->
      $editable.remove()

    describe "#constructor", ->
      defaults = config = null
      beforeEach ->
        defaults =
          plugins: []
          toolbar: []
        config =
          assets:
            templates: "spec/javascripts/support/fixtures/templates.html"

      it "saves the element as a jQuery element", ->
        editor = new Editor($editable[0], defaults, config)
        expect(editor.$el.attr).toBeDefined()

      it "creates an API", ->
        editor = new Editor($editable[0], defaults, config)
        expect(editor.api).not.toBeNull()

describe "Editor", ->
  required = ["cs!core/editor"]

  $editable = null
  beforeEach ->
    $editable = addEditableFixture()

  afterEach ->
    $editable.remove()

  describe "#constructor", ->
    assets = null
    beforeEach ->
      assets =
        templates: "spec/javascripts/fixtures/templates.html"

    ait "saves the element as a jQuery element", required, (Editor) ->
      editor = new Editor($editable[0], {}, assets: assets)
      expect(editor.$el.attr).toBeDefined()

    ait "creates an API", required, (Editor) ->
      editor = new Editor($editable[0], {},  assets: assets)
      expect(editor.api).not.toBeNull()

    ait "registers the plugins", required, (Editor) ->
      plugin =
        register: ->
        getDefaultToolbar: ->
        getToolbar: ->
      editor = new Editor($editable[0], {}, assets: assets, plugins: [plugin])
      expect(editor.defaultToolbarPlugins.length).toBeGreaterThan(0)
      expect(editor.toolbarPlugins.length).toEqual(1)
      expect(editor.keyboardPlugins.length).toBeGreaterThan(0)

  describe "#addToolbarPlugin", ->
    ait "throws an error if there is no #getDefaultToolbar()", required, (Editor) ->
      plugin =
        register: (api) ->,
        getToolbar: -> TestButton: "html"
      expect(-> new Editor($editable[0], plugins: [plugin])).toThrow()

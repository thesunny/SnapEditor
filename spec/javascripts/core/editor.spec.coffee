describe "Editor", ->
  required = ["cs!core/editor"]

  $editable = null
  beforeEach ->
    $editable = addEditableFixture()

  afterEach ->
    $editable.remove()

  describe "#constructor", ->
    ait "saves the element as a jQuery element", required, (Editor) ->
      editor = new Editor($editable[0])
      expect(editor.$el.attr).toBeDefined()

    ait "creates an API", required, (Editor) ->
      editor = new Editor($editable[0])
      expect(editor.api).not.toBeNull()

    ait "stores the given toolbar", required, (Editor) ->
      editor = new Editor($editable[0], toolbar: "toolbar")
      expect(editor.toolbarConfig).toEqual("toolbar")

    ait "stores the default toolbar config if none is given", required, (Editor) ->
      editor = new Editor($editable[0])
      expect(editor.toolbarConfig).toBeDefined()
      expect(editor.toolbarConfig).not.toBeNull()

    ait "registers the plugins", required, (Editor) ->
      spyOn(Editor.prototype, "registerPlugins")
      editor = new Editor($editable[0], plugins: "plugins")
      expect(editor.registerPlugins).toHaveBeenCalled()

  describe "#addToolbarPlugin", ->
    ait "throws an error if there is no #getDefaultToolbar()", required, (Editor) ->
      plugin = {
        register: (api) ->,
        getToolbar: -> TestButton: "html"
      }
      expect(-> new Editor($editable[0], plugins: [plugin])).toThrow()

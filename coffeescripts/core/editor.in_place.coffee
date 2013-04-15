define ["core/editor", "config/config.default.in_place", "core/toolbar/toolbar.floating"], (Editor, Defaults, Toolbar) ->
  class InPlaceEditor extends Editor
    constructor: (el, config = {}) ->
      super(el, SnapEditor.InPlace.config, config)

    # Perform the actual initialization of the editor.
    init: (el) =>
      super(el)
      @toolbar = new Toolbar(@api)

    prepareConfig: ->
      super()
      @config.snap = @defaults.snap if typeof @config.snap == "undefined"
      @config.buttons = @config.buttons.concat(["|", "save", "exit"]) if @config.onSave

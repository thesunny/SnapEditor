define ["core/editor", "config/config.default.in_place", "core/toolbar/toolbar.floating"], (Editor, Defaults, Toolbar) ->
  class InPlaceEditor extends Editor
    constructor: (el, config) ->
      defaults = Defaults.build()
      if config.onSave
        if config.toolbar
          config.toolbar.items = config.toolbar.items.concat(["|", "save", "exit"])
        else
          defaults.toolbar.items = defaults.toolbar.items.concat(["|", "save", "exit"])
      super(el, defaults, config)

    # Perform the actual initialization of the editor.
    init: (el) =>
      super(el)
      @toolbar = new Toolbar(@api)

    prepareConfig: ->
      super()
      @config.snap = @defaults.snap if typeof @config.snap == "undefined"

  return InPlaceEditor

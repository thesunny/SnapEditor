define ["core/editor", "config/config.default.in_place", "core/toolbar/toolbar.floating"], (Editor, Defaults, Toolbar) ->
  class InPlaceEditor extends Editor
    constructor: (el, config) ->
      defaults = Defaults.build()
      if config.onSave
        if config.toolbar
          config.toolbar = config.toolbar.concat(["|", "SaveCancel"])
        else
          defaults.toolbar = defaults.toolbar.concat(["|", "SaveCancel"])
      super(el, defaults, config)
      toolbarComponents = @plugins.getToolbarComponents()
      @toolbar = new Toolbar(@api, @$templates, toolbarComponents.available, toolbarComponents.config)

    prepareConfig: ->
      super()
      @config.snap = @defaults.snap if typeof @config.snap == "undefined"

  return InPlaceEditor

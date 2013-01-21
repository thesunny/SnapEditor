define ["core/editor", "config/config.default.in_place", "core/toolbar/toolbar.floating"], (Editor, Defaults, Toolbar) ->
  class InPlaceEditor extends Editor
    constructor: (el, config) ->
      defaults = Defaults.build()
      defaults.toolbar = defaults.toolbar.concat(["|", "SaveCancel"]) if config.onSave
      super(el, defaults, config)
      toolbarComponents = @plugins.getToolbarComponents()
      @toolbar = new Toolbar(@api, @$templates, toolbarComponents.available, toolbarComponents.config)

  return InPlaceEditor

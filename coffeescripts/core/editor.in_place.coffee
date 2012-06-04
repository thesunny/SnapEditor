define ["core/editor", "config/config.default.in_place", "core/toolbar/toolbar.floating"], (Editor, Defaults, Toolbar) ->
  class InPlaceEditor extends Editor
    constructor: (el, config) ->
      super(el, Defaults.build(), config)
      toolbarComponents = @plugins.getToolbarComponents()
      @toolbar = new Toolbar(@api, @$templates, toolbarComponents.available, toolbarComponents.config)

  return InPlaceEditor

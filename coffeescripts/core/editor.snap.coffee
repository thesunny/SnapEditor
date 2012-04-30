define ["core/editor", "config/config.default.snap", "core/toolbar/toolbar.floating"], (Editor, Defaults, Toolbar) ->
  class SnapEditor extends Editor
    constructor: (el, config) ->
      super(el, Defaults.build(), config)
      toolbarComponents = @plugins.getToolbarComponents()
      @toolbar = new Toolbar(@api, @$templates, toolbarComponents.available, toolbarComponents.config)

  return SnapEditor

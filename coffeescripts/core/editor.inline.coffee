define ["core/editor", "config/config.default.inline", "core/toolbar/toolbar.floating"], (Editor, Defaults, Toolbar) ->
  class InlineEditor extends Editor
    constructor: (el, config) ->
      super(el, Defaults.build(), config)
      toolbarComponents = @plugins.getToolbarComponents()
      @toolbar = new Toolbar(@api, @$templates, toolbarComponents.available, toolbarComponents.config)

  return InlineEditor

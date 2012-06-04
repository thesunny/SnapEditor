define ["core/editor", "config/config.default.form", "core/formizer", "core/toolbar/toolbar.static"], (Editor, Defaults, Formizer, Toolbar) ->
  class FormEditor extends Editor
    constructor: (el, config) ->
      # Transform the string into a CSS id selector.
      el = "#" + el if typeof el == "string"
      @formizer = new Formizer($(el))
      super(@formizer.$content, Defaults.build(), config)
      toolbarComponents = @plugins.getToolbarComponents()
      @toolbar = new Toolbar(@api, @$templates, toolbarComponents.available, toolbarComponents.config)
      @formizer.formize(@toolbar.$toolbar)

  return FormEditor

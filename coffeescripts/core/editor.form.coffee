define ["core/editor", "config/config.default.form", "plugins/toolbar/toolbar.static", "plugins/formizer/formizer"], (Editor, Defaults, Toolbar, Formizer) ->
  class FormEditor extends Editor
    constructor: (el, config) ->
      @formizer = new Formizer($(el))
      super(@formizer.$content, Defaults.build(), config)
      @formizer.formize(@toolbar.$toolbar)

    setupPlugins: ->
      super
      @toolbar = new Toolbar(@$templates, @defaultToolbarPlugins, @toolbarPlugins, @defaults.toolbar, @config.toolbar)
      @registerPlugin(@toolbar)

  return FormEditor

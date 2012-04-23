define ["cs!core/editor", "cs!config/config.default.form", "cs!plugins/toolbar/toolbar.static", "cs!plugins/formizer/formizer"], (Editor, Defaults, Toolbar, Formizer) ->
  class FormEditor extends Editor
    constructor: (el, config) ->
      super(el, Defaults.build(), config)

    setupPlugins: ->
      super
      @toolbar = new Toolbar(@$templates, @defaultToolbarPlugins, @toolbarPlugins, @defaults.toolbar, @config.toolbar)
      @registerPlugin(@toolbar)
      @formizer = new Formizer(@$el, @toolbar.$toolbar)
      @formizer.call()

  return FormEditor

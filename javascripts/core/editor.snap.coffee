define ["cs!core/editor", "cs!config/config.default.snap", "cs!plugins/toolbar/toolbar.floating"], (Editor, Defaults, Toolbar) ->
  class SnapEditor extends Editor
    constructor: (el, config) ->
      super(el, Defaults.build(), config)

    setupPlugins: ->
      super
      @toolbar = new Toolbar(@$templates, @defaultToolbarPlugins, @toolbarPlugins, @defaults.toolbar, @config.toolbar)
      @registerPlugin(@toolbar)

  return SnapEditor

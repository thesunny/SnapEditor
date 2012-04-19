define ["cs!core/editor", "cs!config/config.default.snap", "cs!plugins/toolbar/toolbar.floating"], (Editor, Defaults, Toolbar) ->
  class SnapEditor extends Editor
    getDefaults: ->
      return @defaults if @defaults
      super
      @defaults.plugins = @defaults.plugins.concat(Defaults.plugins)
      @defaults.toolbar = Defaults.toolbar if Defaults.toolbar
      return @defaults

    setupPlugins: ->
      super
      @toolbar = new Toolbar(@$templates, @defaultToolbarPlugins, @toolbarPlugins, @getDefaults().toolbar, @config.toolbar)
      @registerPlugin(@toolbar)

  return SnapEditor

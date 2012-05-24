define ["core/toolbar/toolbar"], (Toolbar) ->
  class StaticToolbar extends Toolbar
    constructor: ->
      super(arguments...)
      @setup()
      @$toolbar.hide().appendTo("body")

    setup: ->
      super
      @$toolbar.addClass("snapeditor_toolbar_static")

    # Shows the toolbar.
    show: ->
      @$toolbar.show()

  return StaticToolbar

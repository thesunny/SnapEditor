define ["core/toolbar/toolbar"], (Toolbar) ->
  class StaticToolbar extends Toolbar
    constructor: ->
      super(arguments...)
      @setup()
      @$toolbar.hide().appendTo("body")

    # Shows the toolbar.
    show: ->
      @$toolbar.show()

  return StaticToolbar

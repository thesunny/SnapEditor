define ["plugins/toolbar/toolbar"], (Toolbar) ->
  class StaticToolbar extends Toolbar
    register: (@api) ->
      @setup()
      @$toolbar.hide().appendTo("body")

    # Shows the toolbar.
    show: ->
      @$toolbar.show()

  return StaticToolbar

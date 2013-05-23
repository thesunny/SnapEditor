define ["core/toolbar/toolbar"], (Toolbar) ->
  class StaticToolbar extends Toolbar
    constructor: ->
      super(arguments...)
      @setup()
      @$toolbar.hide().appendTo("body")

    staticCSS: """
      .snapeditor_toolbar_static {
        width: 100%;
      }
    """

    setup: ->
      super
      @editor.insertStyles("snapeditor_toolbar_static", @staticCSS)
      @$toolbar.addClass("snapeditor_toolbar_static")

    # Shows the toolbar.
    show: ->
      @$toolbar.show()

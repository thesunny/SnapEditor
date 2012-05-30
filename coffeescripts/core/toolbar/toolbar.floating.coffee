define ["core/toolbar/toolbar", "core/toolbar/toolbar.floating.displayer"], (Toolbar, Displayer) ->
  class FloatingToolbar extends Toolbar
    constructor: ->
      super(arguments...)
      @api.on("activate.editor", @show)
      @api.on("deactivate.editor", @hide)

    setup: ->
      super
      @$toolbar.addClass("snapeditor_toolbar_floating")
      @displayer = new Displayer(@$toolbar, @api.el, @api)
      @dataActionHandler.activate()

    # Shows the toolbar.
    show: =>
      @setup() unless @$toolbar
      @displayer.show()

    # Hides the toolbar.
    hide: =>
      @displayer.hide() if @$toolbar

  return FloatingToolbar

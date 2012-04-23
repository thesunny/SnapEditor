define ["plugins/toolbar/toolbar", "plugins/toolbar/toolbar.floating.displayer"], (Toolbar, Displayer) ->
  class FloatingToolbar extends Toolbar
    register: (@api) ->
      @api.on("activate.editor", @show)
      @api.on("deactivate.editor", @hide)

    setup: ->
      super
      @displayer = new Displayer(@$toolbar, @api.el, @api)

    # Shows the toolbar.
    show: =>
      @setup() unless @$toolbar
      @displayer.show()

    # Hides the toolbar.
    hide: =>
      @displayer.hide() if @$toolbar

  return FloatingToolbar

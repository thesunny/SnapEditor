define ["core/toolbar/toolbar", "core/toolbar/toolbar.floating.displayer"], (Toolbar, Displayer) ->
  class FloatingToolbar extends Toolbar
    constructor: ->
      super(arguments...)
      @editor.on("snapeditor.activate", @show)
      @editor.on("snapeditor.deactivate", @hide)

    floatCSS: """
      .snapeditor_toolbar_floating {
        position: relative;
        z-index: 200;
        margin: 0;
        padding: 2px 0;
      }

      .snapeditor_toolbar_floating .snapeditor_toolbar_frame {
        border: 1px solid #b8b8b8;
        -webkit-border-radius: 4px;
        -moz-border-radius: 4px;
        border-radius: 4px;
        background: #FBFBFB;
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#FFFFFF', endColorstr='#F8F8F8');
        background: -webkit-gradient(linear, left top, left bottom, from(#FFFFFF), to(#F8F8F8));
        background: -moz-linear-gradient(top,  #FFFFFF,  #F8F8F8);
        margin: 0px;
        padding: 4px;
      }
    """

    setup: ->
      super
      @editor.insertStyles("snapeditor_toolbar_floating", @floatCSS)
      @$toolbar.addClass("snapeditor_toolbar_floating")
      @displayer = new Displayer(@$toolbar, @editor.el, @editor)
      @dataActionHandler.activate()

    # Shows the toolbar.
    show: =>
      @setup() unless @$toolbar
      @displayer.show()

    # Hides the toolbar.
    hide: =>
      @displayer.hide() if @$toolbar

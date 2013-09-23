# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["core/toolbar/toolbar.menu.toolbar", "core/toolbar/toolbar.floating.displayer"], (Toolbar, Displayer) ->
  class FloatingToolbar extends Toolbar
    constructor: ->
      super(arguments...)
      @options.editor.on("snapeditor.activate", @show)
      @options.editor.on("snapeditor.deactivate", @hide)

    floatCSS: ->
      """
        .snapeditor_toolbar_floating {
          position: relative;
          z-index: #{SnapEditor.zIndexBase + 100};
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
      unless @$el
        super
        @options.editor.insertStyles("snapeditor_toolbar_floating", @floatCSS())
        @$el.addClass("snapeditor_toolbar_floating")
        @displayer = new Displayer(@$el, @options.editor.el, @options.editor)

    # Shows the toolbar.
    show: =>
      unless @shown
        super
        @displayer.show()
      # Prevent the if statement from above from returning false and stopping
      # propagation.
      return true

    # Hides the toolbar.
    hide: =>
      if @shown
        super
        @displayer.hide()
      # Prevent the if statement from above from returning false and stopping
      # propagation.
      return true

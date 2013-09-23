# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["core/toolbar/toolbar.menu.toolbar"], (Toolbar) ->
  class StaticToolbar extends Toolbar
    constructor: ->
      super(arguments...)
      @show()

    staticCSS: """
      .snapeditor_toolbar_static {
        width: 100%;
      }
    """

    setup: ->
      unless @$el
        super
        @options.editor.insertStyles("snapeditor_toolbar_static", @staticCSS)
        @$el.addClass("snapeditor_toolbar_static")

# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["core/editor", "config/config.default.in_place", "core/toolbar/toolbar.floating"], (Editor, Defaults, Toolbar) ->
  class InPlaceEditor extends Editor
    constructor: (el, config = {}) ->
      super(el, SnapEditor.InPlace.config, config)

    # Perform the actual initialization of the editor.
    init: (el) =>
      super(el)
      @toolbar = new Toolbar(@config.toolbar, editor: this)

    prepareConfig: ->
      super
      @config.snap = @defaults.snap if typeof @config.snap == "undefined"
      @config.toolbar.appendItems(["|", "save", "discard"]) if @config.onSave

# NOTE: There is no spec file for this file because the cut/copy/paste
# functionalities cannot be copied using execCommand. They are prohibited by
# the browser unless the user allows it through his/her preferences. Therefore,
# this needs to be manually tested.
define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  window.SnapEditor.internalPlugins.edit =
    events:
      activate: (e) -> e.api.config.plugins.edit.activate(e.api)
      deactivate: (e) -> e.api.config.plugins.edit.deactivate(e.api)

    activate: (api) ->
      api.on(
        "snapeditor.keydown": @onkeydown
        "snapeditor.keyup": @onkeyup
      )

    deactivate: (api) ->
      api.off(
        "snapeditor.keydown": @onkeydown
        "snapeditor.keyup": @onkeyup
      )

    onkeydown: (e) ->
      api = e.api
      plugin = api.config.plugins.edit
      keys = Helpers.keysOf(e)
      switch keys
        when "ctrl.v"
          plugin.pasteOccurred = true
          # On paste, we want to save the start of the selection. We don't care
          # about the end of the selection yet.
          [startParent, endParent] = api.getParentElements((el) -> Helpers.isBlock(el))
          # We take the parent's sibling because it is possible that the parent
          # gets deleted along with the paste.
          plugin.pasteStartParent = startParent and startParent.previousSibling
        when "ctr.x"
          plugin.cutOccurred = true

    onkeyup: (e) ->
      api = e.api
      plugin = api.config.plugins.edit
      keys = Helpers.keysOf(e)
      switch keys
        when "ctrl.v", "v" then plugin.paste(api)
        when "ctrl.x", "x" then plugin.cut(api)

    cut: (api) ->
      if @cutOccurred
        @cutOccurred = false
        # Cleanup after the content has been cut.
        api.clean()

    paste: (api) ->
      if @pasteOccurred
        @pasteOccurred = false
        # If the pasteStartParent is invalid, we just clean from the start of the
        # editor.
        pasteStartParent = @pasteStartParent or api.el.firstChild
        # In all browsers, after a paste, the selection is collapsed at the end
        # of the paste. We use this to find the parent of the end of the paste.
        # If there is no parent, we clean until the end of the editor.
        pasteEndParent = api.getParentElement((el) -> Helpers.isBlock(el)) or api.el.lastChild
        api.clean(pasteStartParent, pasteEndParent)
        @pasteStartParent = null

define ["core/helpers"], (Helpers) ->
  class Edit
    register: (@api) ->
      @$el = $(@api.el)
      @api.on("activate.editor", @activate)
      @api.on("deactivate.editor", @deactivate)

    getUI: (ui) ->
      cut = ui.button(action: "cut", title: "Cut (Ctrl+X)", icon: "image.png")
      copy = ui.button(action: "copy", title: "Copy (Ctrl+C)", icon: "image.png")
      paste = ui.button(action: "paste", title: "Paste (Ctrl+V)", icon: "image.png")
      return {
        "context:default": [cut, copy, paste]
      }

    getActions: ->
      return {
        cut: -> alert("Please use CTRL+X (or Command if you're on a Mac)")
        copy: -> alert("Please use CTRL+C (or Command if you're on a Mac)")
        paste: -> alert("Please use CTRL+V (or Command if you're on a Mac)")
      }

    activate: =>
      @$el.on("keydown", @onkeydown)
      @$el.on("keyup", @onkeyup)

    deactivate: =>
      @$el.off("keydown", @onkeydown)
      @$el.off("keyup", @onkeyup)

    onkeydown: (e) =>
      keys = Helpers.keysOf(e)
      if keys == "ctrl.v"
        # On paste, we want to save the start of the selection. We don't care
        # about the end of the selection yet.
        [@pasteStartParent, endParent] = @api.getParentElements((el) -> Helpers.isBlock(el))

    onkeyup: (e) =>
      keys = Helpers.keysOf(e)
      switch keys
        when "ctrl.v" then @paste()
        when "ctrl.x" then @cut()

    cut: ->
      # Cleanup after the content has been cut.
      @api.clean()

    paste: ->
      # In all browsers, after a paste, the selection is collapsed at the end
      # of the paste. We use this to find the parent of the end of the paste.
      pasteEndParent = @api.getParentElement((el) -> Helpers.isBlock(el))
      @api.clean(@pasteStartParent, pasteEndParent)
      @pasteStartParent = null

  return Edit

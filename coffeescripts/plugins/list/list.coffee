define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  class List
    register: (@api) ->
      @api.on("activate.editor", @activate)
      @api.on("deactivate.editor", @deactivate)

    getUI: (ui) ->
      unorderedList = ui.button(action: "unorderedList", description: "Bullet List", shortcut: "Ctrl+Shift+8", icon: { url: @api.assets.image("text_list_bullets.png"), width: 24, height: 24, offset: [3, 3] })
      orderedList = ui.button(action: "orderedList", description: "Numbered List", shortcut: "Ctrl+Shift+7", icon: { url: @api.assets.image("text_list_numbers.png"), width: 24, height: 24, offset: [3, 3] })
      indent = ui.button(action: "indent", description: "Indent", icon: { url: @api.assets.image("text_indent.png"), width: 24, height: 24, offset: [3, 3] })
      outdent = ui.button(action: "outdent", description: "Outdent", icon: { url: @api.assets.image("text_indent_remove.png"), width: 24, height: 24, offset: [3, 3] })
      return {
        "toolbar:default": "list"
        list: [unorderedList, orderedList, indent, outdent]
        unorderedList: unorderedList
        orderedList: orderedList
        indent: indent
        outdent: outdent
      }

    getActions: ->
      return {
        unorderedList: @unorderedList
        orderedList: @orderedList
        indent: @indent
        outdent: @outdent
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.shift.8": "unorderedList"
        "ctrl.shift.7": "orderedList"
      }

    unorderedList: =>
      @update() if @api.insertUnorderedList()

    orderedList: =>
      @update() if @api.insertOrderedList()

    indent: =>
      @update() if @api.indent()

    outdent: =>
      @update() if @api.outdent()

    update: ->
      console.log "UPDATE"
      # In Firefox, when a user clicks on the toolbar to style, the
      # editor loses focus. Instead, the focus is set on the toolbar
      # button (even though unselectable="on"). Whenever the user
      # types a character, it inserts it into the editor, but also
      # presses the toolbar button. This can result in alternating
      # behaviour. For example, if I click on the list button. When
      # I start typing, it will toggle lists on and off.
      # This cannot be called for IE because it will cause the window to scroll
      # and jump. Hence this is only for Firefox.
      @api.el.focus() if Browser.isMozilla
      @api.clean()
      @api.update()

    activate: =>
      $(@api.el).on("keydown", @onkeydown)

    deactivate: =>
      $(@api.el).off("keydown", @onkeydown)

    onkeydown: (e) =>
      keys = Helpers.keysOf(e)
      if (keys == "tab" or keys == "shift.tab") and @api.getParentElement("li")
        e.preventDefault()
        if keys == "tab" then @indent() else @outdent()

  return List

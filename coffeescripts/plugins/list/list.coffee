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
      @api.clean()
      @api.update()

    activate: =>
      $(@api.el).on("keydown", @onkeydown)

    deactivate: =>
      $(@api.el).off("keydown", @onkeydown)

    onkeydown: (e) =>
      keys = Helpers.keysOf(e)
      if (keys == "tab" or keys == "shift.tab") 
        [startItem, endItem] = @api.getParentElements("li")
        if startItem and endItem
          e.preventDefault()
          if keys == "tab" then @indent() else @outdent()

  return List

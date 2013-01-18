define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  class List
    register: (@api) ->
      @api.on("snapeditor.activate", @activate)
      @api.on("snapeditor.deactivate", @deactivate)

    getUI: (ui) ->
      orderedList = ui.button(action: "orderedList", description: @api.lang.numberedList, shortcut: "Ctrl+Shift+7", icon: { url: @api.assets.image("text_list_numbers.png"), width: 24, height: 24, offset: [3, 3] })
      unorderedList = ui.button(action: "unorderedList", description: @api.lang.bulletedList, shortcut: "Ctrl+Shift+8", icon: { url: @api.assets.image("text_list_bullets.png"), width: 24, height: 24, offset: [3, 3] })
      indent = ui.button(action: "indent", description: @api.lang.indent, shortcut: "Tab", icon: { url: @api.assets.image("text_indent.png"), width: 24, height: 24, offset: [3, 3] })
      outdent = ui.button(action: "outdent", description: @api.lang.outdent, shortcut: "Shift+Tab", icon: { url: @api.assets.image("text_indent_remove.png"), width: 24, height: 24, offset: [3, 3] })
      return {
        "toolbar:default": "list"
        list: [orderedList, unorderedList, indent, outdent]
        orderedList: orderedList
        unorderedList: unorderedList
        indent: indent
        outdent: outdent
      }

    getActions: ->
      return {
        orderedList: @orderedList
        unorderedList: @unorderedList
        indent: @indent
        outdent: @outdent
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.shift.8": "unorderedList"
        "ctrl.shift.7": "orderedList"
      }

    orderedList: =>
      @update() if @api.insertOrderedList()

    unorderedList: =>
      @update() if @api.insertUnorderedList()

    indent: =>
      @update() if @api.indent()

    outdent: =>
      @update() if @api.outdent()

    update: ->
      # In Webkit, after the toolbar is clicked, the focus hops to the parent
      # window. We need to refocus it back into the iframe. Focusing breaks IE
      # and kills the range so the focus is only for Webkit. It does not affect
      # Firefox.
      @api.win.focus() if Browser.isWebkit
      @api.clean()

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

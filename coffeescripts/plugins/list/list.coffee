define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  class List
    register: (@api) ->

    getUI: (ui) ->
      unorderedList = ui.button(action: "unorderedList", description: "Bullet List", shortcut: "Ctrl+Shift+8", icon: { url: @api.assets.image("text_list_bullets.png"), width: 24, height: 24, offset: [3, 3] })
      orderedList = ui.button(action: "orderedList", description: "Numbered List", shortcut: "Ctrl+Shift+7", icon: { url: @api.assets.image("text_list_numbers.png"), width: 24, height: 24, offset: [3, 3] })
      return {
        "toolbar:default": "list"
        list: [unorderedList, orderedList]
        unorderedList: unorderedList
        orderedList: orderedList
      }

    getActions: ->
      return {
        unorderedList: @unorderedList
        orderedList: @orderedList
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

    update: ->
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

  return List

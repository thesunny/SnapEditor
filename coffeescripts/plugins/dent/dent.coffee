define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  class Dent
    register: (@api) ->

    getUI: (ui) ->
      indent = ui.button(action: "indent", description: "Indent", icon: { url: @api.assets.image("text_indent.png"), width: 24, height: 24, offset: [3, 3] })
      outdent = ui.button(action: "outdent", description: "Outdent", icon: { url: @api.assets.image("text_indent_remove.png"), width: 24, height: 24, offset: [3, 3] })
      return {
        "toolbar:default": "dent"
        dent: [indent, outdent]
        indent: indent
        outdent: outdent
      }

    getActions: ->
      return {
        indent: @indent
        outdent: @outdent
      }

    getKeyboardShortcuts: ->
      return {
      }

    indent: =>
      @update() if @api.indent()

    outdent: =>
      @update() if @api.outdent()

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

  return Dent

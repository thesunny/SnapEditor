define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  class Block
    register: (@api) ->

    getUI: (ui) ->
      left = ui.button(action: "alignLeft", description: @api.lang.alignLeft, shortcut: "Ctrl+L", icon: { url: @api.assets.image("text_align_left.png"), width: 24, height: 24, offset: [3, 3] })
      centre = ui.button(action: "alignCentre", description: @api.lang.alignCentre, shortcut: "Ctrl+E", icon: { url: @api.assets.image("text_align_centre.png"), width: 24, height: 24, offset: [3, 3] })
      right = ui.button(action: "alignRight", description: @api.lang.alignRight, shortcut: "Ctrl+R", icon: { url: @api.assets.image("text_align_right.png"), width: 24, height: 24, offset: [3, 3] })
      justify = ui.button(action: "alignJustify", description: @api.lang.alignJustify, shortcut: "Ctrl+J", icon: { url: @api.assets.image("text_align_justify.png"), width: 24, height: 24, offset: [3, 3] })
      return {
        "toolbar:default": "align"
        align: [left, centre, right, justify]
        alignLeft: left
        alignCentre: centre
        alignRight: right
        alignJustify: justify
      }

    getActions: ->
      return {
        alignLeft: Helpers.pass(@align, "left")
        alignCentre: Helpers.pass(@align, "centre")
        alignRight: Helpers.pass(@align, "right")
        alignJustify: Helpers.pass(@align, "justify")
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.l": "alignLeft"
        "ctrl.e": "alignCentre"
        "ctrl.r": "alignRight"
        "ctrl.j": "alignJustify"
      }

    align: (how) =>
      @update() if @api.align(how)

    update: ->
      # In Webkit, after the toolbar is clicked, the focus hops to the parent
      # window. We need to refocus it back into the iframe. Focusing breaks IE
      # and kills the range so the focus is only for Webkit. It does not affect
      # Firefox.
      @api.win.focus() if Browser.isWebkit
      @api.clean()

  return Block

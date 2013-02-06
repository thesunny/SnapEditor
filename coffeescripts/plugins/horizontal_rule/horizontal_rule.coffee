define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  class InlineStyler
    register: (@api) ->

    getUI: (ui) ->
      horizontalrule = ui.button(action: "horizontalrule", description: @api.lang.horizontalRule, shortcut: "Ctrl+=", icon: { url: @api.assets.image("text_horizontalrule.png"), width: 24, height: 24, offset: [3, 3] })
      return {
        "toolbar:default": "horizontalrule"
        horizontalrule: horizontalrule
      }

    getActions: ->
      return {
        horizontalrule: @horizontalrule
      }

    getKeyboardShortcuts: ->
      return {
        "ctrl.=": "horizontalrule"
      }

    horizontalrule: =>
      @update() if @api.insertHorizontalRule()

    update: ->
      # In Webkit, after the toolbar is clicked, the focus hops to the parent
      # window. We need to refocus it back into the iframe. Focusing breaks IE
      # and kills the range so the focus is only for Webkit. It does not affect
      # Firefox.
      @api.win.focus() if Browser.isWebkit
      @api.clean()

  return InlineStyler

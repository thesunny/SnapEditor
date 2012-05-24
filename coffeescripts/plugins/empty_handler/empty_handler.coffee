define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  class EmptyHandler
    register: (@api) ->
      @api.on("activate.editor", @activate)
      @api.on("deactivate.editor", @deactivate)

    activate: =>
      $(@api.el).on("keyup", @onkeyup)

    deactivate: =>
      $(@api.el).off("keyup", @onkeyup)

    onkeyup: (e) =>
      key = Helpers.keyOf(e)
      if (key == 'delete' or key == 'backspace') and @isEmpty()
        @deleteAll()

    # Returns true if the editor has no text. False otherwise.
    isEmpty: ->
      $(@api.el).text().replace(/[\n\r\t ]/g, "").length == 0

    # Removes all content and appends the default block. It then places the
    # selection at the end of the block.
    deleteAll: ->
      $el = $(@api.el)
      $block = $(@api.defaultBlock()).html(Helpers.zeroWidthNoBreakSpace)
      $el.empty()
      $el.append($block)
      @api.selectEndOfElement($block[0])

  return EmptyHandler

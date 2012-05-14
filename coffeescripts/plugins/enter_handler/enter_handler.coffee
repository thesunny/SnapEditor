define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  class EnterHandler
    register: (@api) ->
      @api.on("activate.editor", @activate)
      @api.on("deactivate.editor", @deactivate)

    activate: =>
      $(@api.el).on("keydown", @onkeydown)

    deactivate: =>
      $(@api.el).off("keydown", @onkeydown)

    onkeydown: (e) =>
      if Helpers.keyOf(e) == "enter"
        e.preventDefault()
        @handleEnterKey()

    handleEnterKey: ->
      @api.delete()
      parent = @api.getParentElement()
      next = @api.next(parent)
      if $(next).tagName() == "br"
        @handleBR(next)
      else
        @handleBlock(parent, next)

    handleBR: (next) ->
      # When there is no text after the <br>, the caret cannot be placed
      # afterwards. With the zero width break space, the caret can now be
      # placed after the <br>.
      @api.paste("#{next.outerHTML}#{Helpers.zeroWidthNoBreakSpace}")

    handleBlock: (block, next) ->
      if @api.isEndOfElement(block)
        $(next).insertAfter(block).html(Helpers.zeroWidthNoBreakSpace)
        @api.selectEndOfElement(next)
      else
        @api.keepRange((startEl, endEl) =>
          $span = $('<span id="ENTER_HANDLER"/>').insertBefore(startEl)
          $(block).split($span)
          $span.remove()
        )

  return EnterHandler

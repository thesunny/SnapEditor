define ["jquery.custom", "core/helpers", "core/browser", "plugins/enter_handler/enter_handler.empty_list_item_handler"], ($, Helpers, Browser, EmptyListHandler) ->
  class EnterHandler
    register: (@api) ->
      @api.on("activate.editor", @activate)
      @api.on("deactivate.editor", @deactivate)
      @emptyListHandler = new EmptyListHandler(@api)

    activate: =>
      $(@api.el).on("keydown", @onkeydown)

    deactivate: =>
      $(@api.el).off("keydown", @onkeydown)

    onkeydown: (e) =>
      if Helpers.keysOf(e) == "enter"
        e.preventDefault()
        @handleEnterKey()

    handleEnterKey: ->
      if @api.delete()
        parent = @api.getParentElement()
        next = @api.next(parent)
        if $(next).tagName() == "br"
          @handleBR(next)
        else
          @handleBlock(parent, next)
        @api.clean()

    handleBR: (next) ->
      # When there is no text after the <br>, the caret cannot be placed
      # afterwards. With the zero width break space, the caret can now be
      # placed after the <br>.
      @api.paste("#{next.outerHTML}#{Helpers.zeroWidthNoBreakSpace}")

    handleBlock: (block, next) ->
      isEndOfElement = @api.isEndOfElement(block)
      if $(block).tagName() == "li" and isEndOfElement and @api.isStartOfElement(block)
        @emptyListHandler.handle(block)
      else if isEndOfElement
        $(next).insertAfter(block).html(Helpers.zeroWidthNoBreakSpace)
        @api.selectEndOfElement(next)
      else
        @api.keepRange((startEl, endEl) ->
          $span = $('<span id="ENTER_HANDLER"/>').insertBefore(startEl)
          [$first, $second] = $(block).split($span)
          # Insert a <br/> if $first is empty.
          if $first[0].childNodes.length == 0 or ($first[0].childNodes.length == 1 and $first[0].firstChild.nodeType == 3 and $first[0].firstChild.nodeValue.match(/^[\n\t ]*$/))
            $first.html("&nbsp;")
          $span.remove()
        )

  return EnterHandler

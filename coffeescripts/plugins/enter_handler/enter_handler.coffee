define ["jquery.custom", "core/helpers", "core/browser"], ($, Helpers, Browser) ->
  class EnterHandler
    register: (@api) ->
      @api.on("snapeditor.activate", @activate)
      @api.on("snapeditor.deactivate", @deactivate)

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
        parent = @getParentElement()
        next = @api.getNext(parent)
        if $(next).tagName() == "br"
          @handleBR(next)
        else
          @handleBlock(parent, next)
        @api.clean()

    getParentElement: ->
      parent = @api.getParentElement()
      # If no parent is found, the text is at the top level. This is not
      # correct and so we have to perform a clean. After the clean, the parent
      # should exist.
      # This can occur right after a table that is at the end of the editable
      # area. The cursor can be placed after the table but before the end of
      # the editable area by using the down/right arrow keys are by simply
      # clicking the area to the right of the table. Text that is entered is at
      # the top level.
      unless parent
        @api.clean()
        parent = @api.getParentElement()
      parent

    handleBR: (next) ->
      # When there is no text after the <br>, the caret cannot be placed
      # afterwards. With the zero width break space, the caret can now be
      # placed after the <br>.
      @api.insert("#{next.outerHTML}#{Helpers.zeroWidthNoBreakSpace}")

    handleBlock: (block, next) ->
      isEndOfElement = @api.isEndOfElement(block)
      if $(block).tagName() == "li" and isEndOfElement and @api.isStartOfElement(block)
        # Empty list item, so outdent.
        @api.outdent()
      else if isEndOfElement
        # Hitting enter at the end of an element. Add the next block and
        # place the selection in it.
        $(next).insertAfter(block).html(Helpers.zeroWidthNoBreakSpace)
        @api.selectEndOfElement(next)
      else
        # In the middle of a block. Split the block and place the selection in
        # the second block.
        @api.keepRange((startEl, endEl) ->
          $span = $('<span id="ENTER_HANDLER"/>').insertBefore(startEl)
          [$first, $second] = $(block).split($span)
          # Insert a <br/> if $first is empty.
          if $first[0].childNodes.length == 0 or ($first[0].childNodes.length == 1 and $first[0].firstChild.nodeType == 3 and $first[0].firstChild.nodeValue.match(/^[\n\t ]*$/))
            $first.html("&nbsp;")
          $span.remove()
        )

  return EnterHandler

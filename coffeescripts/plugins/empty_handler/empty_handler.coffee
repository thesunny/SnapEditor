define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  emptyHandler =
    activate: (@api) ->
      self = this
      @onkeyupHandler = -> (e) -> self.onkeyup(e)
      @api.on("snapeditor.keyup", @onkeyupHandler)

    deactivate: ->
      @api.off("snapeditor.keyup", @onkeyupHandler)

    onkeyup: (e) ->
      key = Helpers.keyOf(e)
      if (key == 'delete' or key == 'backspace') and Helpers.isEmpty(@api.el)
        @deleteAll()

    # After the cleaner has finished, insert the default block if the editor is
    # empty.
    onCleanerFinished: (@api) ->
      if Helpers.isEmpty(@api.el)
        $(@api.el).empty()
        @insertDefaultBlock()

    # Removes all content and appends the default block. It then places the
    # selection at the end of the block.
    deleteAll: ->
      $(@api.el).empty()
      @insertDefaultBlock()

    # Insert the default block into the editor and place the selection at the
    # end of the block.
    insertDefaultBlock: ->
      block = $(@api.getDefaultBlock()).html(Helpers.zeroWidthNoBreakSpace)[0]
      @api.el.appendChild(block)
      @api.selectEndOfElement(block) if @api.isValid()

  SnapEditor.behaviours.emptyHandler =
      onActivate: (e) -> emptyHandler.activate(e.api)
      onDeactivate: (e) -> emptyHandler.deactivate()
      onCleanerFinished: (e) -> emptyHandler.onCleanerFinished(e.api)

  # emptyHandler is returned for testing purposes.
  return emptyHandler

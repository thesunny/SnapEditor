define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  window.SnapEditor.internalPlugins.emptyHandler =
    events:
      activate: (e) -> e.api.on("snapeditor.keyup", e.api.config.plugins.emptyHandler.onkeyup)
      deactivate: (e) -> e.api.off("snapeditor.keyup", e.api.config.plugins.emptyHandler.onkeyup)
      cleanerFinished: (e) -> e.api.config.plugins.emptyHandler.onCleanerFinished(e.api)

    onkeyup: (e) ->
      api = e.api
      plugin = api.config.emptyHandler
      key = Helpers.keyOf(e)
      if (key == 'delete' or key == 'backspace') and plugin.isEmpty(api.el)
        plugin.deleteAll(api)

    # After the cleaner has finished, insert the default block if the editor is
    # empty.
    onCleanerFinished: (api) ->
      if @isEmpty(api.el)
        $(api.el).empty()
        @insertDefaultBlock(api)

    # Returns true if the editor has no text. False otherwise.
    isEmpty: (el) ->
      $(el).text().replace(/[\n\r\t ]/g, "").length == 0

    # Removes all content and appends the default block. It then places the
    # selection at the end of the block.
    deleteAll: (api) ->
      $(api.el).empty()
      @insertDefaultBlock(api)

    # Insert the default block into the editor and place the selection at the
    # end of the block.
    insertDefaultBlock: (api) ->
      block = $(api.getDefaultBlock()).html(Helpers.zeroWidthNoBreakSpace)[0]
      api.el.appendChild(block)
      api.selectEndOfElement(block) if api.isValid()

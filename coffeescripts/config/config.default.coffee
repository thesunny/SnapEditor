define ["plugins/activate/activate", "plugins/editable/editable", "plugins/cleaner/cleaner", "plugins/erase_handler/erase_handler", "plugins/styler/styler.inline", "plugins/styler/styler.block"], (Activate, Editable, Cleaner, EraseHandler, InlineStyler, BlockStyler) ->
  return {
    build: ->
      return {
        plugins: [new Activate(), new Editable(), new Cleaner(), new EraseHandler(), new InlineStyler(), new BlockStyler()]
        toolbar: [
          "Inline", "|",
          "Block"
        ]
        whitelist: {}
      }
  }

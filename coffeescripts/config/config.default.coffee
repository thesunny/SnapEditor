define ["plugins/activate/activate", "plugins/editable/editable", "plugins/cleaner/cleaner", "plugins/erase_handler/erase_handler", "plugins/styler/styler.inline", "plugins/styler/styler.block", "plugins/table/table"], (Activate, Editable, Cleaner, EraseHandler, InlineStyler, BlockStyler, Table) ->
  return {
    build: ->
      return {
        plugins: [new Activate(), new Editable(), new Cleaner(), new EraseHandler(), new InlineStyler(), new BlockStyler(), new Table()],
        toolbar: [
          "Inline", "|",
          "Block", "|",
          "Table"
        ]
      }
  }

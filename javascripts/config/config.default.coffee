define ["cs!plugins/activate/activate", "cs!plugins/editable/editable", "cs!plugins/styler/styler.inline", "cs!plugins/styler/styler.block", "cs!plugins/erase_handler/erase_handler"], (Activate, Editable, InlineStyler, BlockStyler, EraseHandler) ->
  return {
    plugins: [new Activate(), new Editable(), new InlineStyler(), new BlockStyler(), new EraseHandler()],
    toolbar: [
      "Inline", "|",
      "Block"
    ]
  }

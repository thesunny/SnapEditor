
define(["plugins/activate/activate", "plugins/editable/editable", "plugins/styler/styler.inline", "plugins/styler/styler.block", "plugins/erase_handler/erase_handler"], function(Activate, Editable, InlineStyler, BlockStyler, EraseHandler) {
  return {
    build: function() {
      return {
        plugins: [new Activate(), new Editable(), new InlineStyler(), new BlockStyler(), new EraseHandler()],
        toolbar: ["Inline", "|", "Block"]
      };
    }
  };
});

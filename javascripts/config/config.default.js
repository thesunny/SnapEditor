
define(["plugins/activate/activate", "plugins/editable/editable", "plugins/styler/styler.inline", "plugins/styler/styler.block", "plugins/styler/styler.insert", "plugins/erase_handler/erase_handler"], function(Activate, Editable, InlineStyler, BlockStyler, InsertStyler, EraseHandler) {
  return {
    build: function() {
      return {
        plugins: [new Activate(), new Editable(), new InlineStyler(), new BlockStyler(), new InsertStyler(), new EraseHandler()],
        toolbar: ["Inline", "|", "Block", "|", "Insert"]
      };
    }
  };
});

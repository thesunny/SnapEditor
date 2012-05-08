define ["plugins/activate/activate", "plugins/editable/editable", "plugins/cleaner/cleaner", "plugins/erase_handler/erase_handler", "plugins/styler/styler.inline", "plugins/styler/styler.block"], (Activate, Editable, Cleaner, EraseHandler, InlineStyler, BlockStyler) ->
  return {
    build: ->
      return {
        plugins: [new Activate(), new Editable(), new Cleaner(), new EraseHandler(), new InlineStyler(), new BlockStyler()]
        toolbar: [
          "Inline", "|",
          "Block"
        ]
        whitelist: {
          Paragraph: "p"
          Div: "div"
          "Heading 1": "h1"
          "Heading 2": "h2"
          "Heading 3": "h3"
          "Unordered List": "ul"
          "Ordered List": "ol"
          "List Item": "li"
          "*": "Paragraph"
        }
      }
  }

define ["plugins/activate/activate", "plugins/editable/editable", "plugins/cleaner/cleaner", "plugins/erase_handler/erase_handler", "plugins/enter_handler/enter_handler", "plugins/edit/edit", "plugins/styler/styler.inline", "plugins/styler/styler.block", "plugins/table/table"], (Activate, Editable, Cleaner, EraseHandler, EnterHandler, Edit, InlineStyler, BlockStyler, Table) ->
  return {
    build: ->
      return {
        plugins: [new Activate(), new Editable(), new Cleaner(), new EraseHandler(), new EnterHandler(), new Edit(), new InlineStyler(), new BlockStyler(), new Table()]
        toolbar: [
          "Inline", "|",
          "Block", "|",
          "Table"
        ]
        whitelist: {
          # Blocks
          "Paragraph": "p > Paragraph"
          "Div": "div > Div"
          # Headings
          "Heading 1": "h1 > Paragraph"
          "Heading 2": "h2 > Paragraph"
          "Heading 3": "h3 > Paragraph"
          # Lists
          "Unordered List": "ul"
          "Ordered List": "ol"
          "List Item": "li > List Item"
          # Tables
          "Table": "table"
          "Table Body": "tbody"
          "Table Row": "tr"
          "Table Header": "th > BR"
          "Table Cell": "td > BR"
          # BR
          "BR": "br"
          # Inlines
          "Bold": "b"
          "Strong": "strong"
          "Italic": "i"
          "Emphasis": "em"
          "Span": "span"
          # Defaults
          "*": "Paragraph"
        }
      }
  }

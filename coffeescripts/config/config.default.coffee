define ["plugins/activate/activate", "plugins/deactivate/deactivate", "plugins/editable/editable", "plugins/cleaner/cleaner", "plugins/erase_handler/erase_handler", "plugins/enter_handler/enter_handler", "plugins/empty_handler/empty_handler", "plugins/edit/edit", "plugins/styler/styler.inline", "plugins/styler/styler.block", "plugins/table/table"], (Activate, Deactivate, Editable, Cleaner, EraseHandler, EnterHandler, EmptyHandler, Edit, InlineStyler, BlockStyler, Table) ->
  return {
    build: ->
      return {
        plugins: [new Activate(), new Deactivate(), new Editable(), new Cleaner(), new EraseHandler(), new EnterHandler(), new EmptyHandler(), new Edit(), new InlineStyler(), new BlockStyler(), new Table()]
        toolbar: [
          "Bold", "Italic", "|",
          "P", "H1", "H2", "H3", "|",
          "UnorderedList", "OrderedList", "Indent", "Outdent", "|",
          "Link", "Table"
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
          "Italic": "i"
          "Links": "a[href]"
          "Range Start": "span#RANGE_START"
          "Range End": "span#RANGE_END"
          # Defaults
          "*": "Paragraph"
          "strong": "Bold"
          "em": "Italic"
        }
      }
  }

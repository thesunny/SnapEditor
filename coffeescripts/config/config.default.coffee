define ["plugins/activate/activate", "plugins/deactivate/deactivate", "plugins/editable/editable", "plugins/cleaner/cleaner", "plugins/erase_handler/erase_handler", "plugins/enter_handler/enter_handler", "plugins/empty_handler/empty_handler", "plugins/autoscroll/autoscroll", "plugins/edit/edit", "plugins/inline/inline", "plugins/block/block", "plugins/link/link", "plugins/list/list", "plugins/table/table", "plugins/image/image", "plugins/image/image.single_uploader"], (Activate, Deactivate, Editable, Cleaner, EraseHandler, EnterHandler, EmptyHandler, Autoscroll, Edit, Inline, Block, Link, List, Table, Image, SingleImageUploader) ->
  return {
    build: ->
      return {
        plugins: [new Activate(), new Deactivate(), new Editable(), new Cleaner(), new EraseHandler(), new EnterHandler(), new EmptyHandler(), new Autoscroll(), new Edit(), new Inline(), new Block(), new Link(), new List(), new Table(), new Image(), new SingleImageUploader()]
        toolbar: [
          "Inline", "|"
          "Block", "|"
          "List", "|",
          "Link", "Table", "Image"
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
          "Links": "a[href, target]"
          "Range Start": "span#RANGE_START"
          "Range End": "span#RANGE_END"
          # Images
          "Image": "img[src, width, height]"
          # Defaults
          "*": "Paragraph"
          "strong": "Bold"
          "em": "Italic"
        }
      }
  }

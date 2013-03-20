define [
  "plugins/activate/activate"
  "plugins/deactivate/deactivate"
  "plugins/editable/editable"
  "plugins/cleaner/cleaner"
  "plugins/erase_handler/erase_handler"
  "plugins/enter_handler/enter_handler"
  "plugins/empty_handler/empty_handler"
  "plugins/autoscroll/autoscroll"
  "plugins/atomic/atomic"
  "plugins/edit/edit"
  "plugins/inline/inline"
  "plugins/block/block"
  "plugins/align/align"
  "plugins/horizontal_rule/horizontal_rule"
  "plugins/link/link"
  "plugins/list/list"
  "plugins/table/table"
  "plugins/image/image"
  "plugins/image/image.uploader"
  "plugins/print/print"
], (Activate, Deactivate, Editable, Cleaner, EraseHandler, EnterHandler, EmptyHandler, Autoscroll, Atomic, Edit, Inline, Block, Align, HorizontalRule, Link, List, Table, Image, ImageUploader, Print) ->
  return {
    build: ->
      return {
        plugins: [
          new Activate()
          new Deactivate()
          new Editable()
          new Cleaner()
          new EraseHandler()
          new EnterHandler()
          new EmptyHandler()
          new Autoscroll()
          new Atomic()
          new Edit()
          new Inline()
          new Block()
          new Align()
          new HorizontalRule()
          new Link()
          new List()
          new Table()
          new Image()
          new ImageUploader()
          new Print()
        ]
        toolbar: [
          "Inline"
          "|"
          "Block"
          "|"
          "List"
          "|"
          "Link"
          "Table"
          "Image"
        ]
        cleaner:
          whitelist:
            # Blocks
            "Paragraph": "p[style=(text-align)] > Paragraph"
            "Div": "div[style=(text-align)] > Div"
            # Headings
            "Heading 1": "h1[style=(text-align)] > Paragraph"
            "Heading 2": "h2[style=(text-align)] > Paragraph"
            "Heading 3": "h3[style=(text-align)] > Paragraph"
            "Heading 4": "h4[style=(text-align)] > Paragraph"
            "Heading 5": "h5[style=(text-align)] > Paragraph"
            "Heading 6": "h6[style=(text-align)] > Paragraph"
            # Lists
            "Unordered List": "ul"
            "Ordered List": "ol"
            "List Item": "li > List Item"
            # Tables
            "Table": "table"
            "Table Body": "tbody"
            "Table Row": "tr"
            "Table Header": "th[style=(text-align)] > BR"
            "Table Cell": "td[style=(text-align)] > BR"
            # BR
            "BR": "br"
            # HR
            "HR": "hr"
            # Inlines
            "Bold": "b"
            "Italic": "i"
            "Underline": "u"
            "Subscript": "sub"
            "Superscript": "sup"
            "Strikethrough": "del"
            "Link": "a[href, target]"
            "Range Start": "span#RANGE_START"
            "Range End": "span#RANGE_END"
            # Images
            "Image": "img[src, width, height]"
            # Defaults
            "*": "Paragraph"
            "strong": "Bold"
            "em": "Italic"
            "strike": "Strikethrough"
          ignore: []
        lang: "en"
        eraseHandler:
          delete: []
        atomic:
          classname: "atomic"
      }
  }

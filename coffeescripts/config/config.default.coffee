# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
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
  "plugins/error/error"
  "plugins/inline/inline"
  "plugins/style_block/style_block"
  "plugins/align/align"
  "plugins/list/list"
  "plugins/link/link"
  "plugins/table/table"
  "plugins/image/image"
  "plugins/horizontal_rule/horizontal_rule"
  "plugins/print/print"
], (Activate, Deactivate, Editable, Cleaner, EraseHandler, EnterHandler, EmptyHandler, Autoscroll, Atomic, Edit, Error, Inline, StyleBlock, Align, List, Link, Table, Image, HorizontalRule, Print) ->
  SnapEditor.buttons.toolbar =
    items: [
      "styleBlock", "|", "bold", "italic", "|", "orderedList", "unorderedList", "indent", "outdent", "|", "link", "table", "image"
    ]
  SnapEditor.config =
    toolbar: "toolbar"
    behaviours: [
      "activate"
      "deactivate"
      "editable"
      "cleaner"
      "eraseHandler"
      "enterHandler"
      "emptyHandler"
      "autoscroll"
      "atomic"
      "edit"
    ]
    shortcuts: []
    styles: ["p", "h1", "h2", "h3", "h4", "h5", "h6"]
    activateByLinks: true
    cleaner:
      whitelist:
        # BR
        "BR": "br"
        # Range
        "Range Start": "span#RANGE_START"
        "Range End": "span#RANGE_END"
        "Image Range": "img#RANGE_IMAGE[src, width, height]"
      ignore: []
    eraseHandler:
      delete: []
    atomic:
      classname: "atomic"
    widget:
      classname: "widget"

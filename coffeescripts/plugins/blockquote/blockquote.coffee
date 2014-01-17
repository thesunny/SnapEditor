# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["snapeditor.pre", "jquery.custom", "core/browser", "core/helpers"], (SnapEditor, $, Browser, Helpers) ->

  blockquote =
    indent: (e) ->
    outdent: (e) ->

  SnapEditor.defActions
    indentBlockquote: blockquote.indent
    outdentBlockquote: blockquote.outdent

  

  # list =
  #   insert: (e) -> e.api.clean() if e.api["insert#{Helpers.capitalize(e.type)}"]()
  #   dent: (e) -> e.api.clean() if e.api[e.type]()
  #   handleTab: (e) ->
  #     keys = Helpers.keysOf(e)
  #     if (keys == "tab" or keys == "shift+tab")
  #       [startItem, endItem] = e.api.getParentElements("li")
  #       if startItem and endItem
  #         e.preventDefault()
  #         e.api.trigger(if keys == "tab" then "indent" else "outdent")
  
  # # SnapEditor.defActions
  # #   orderedList: list.insert
  # #   unorderedList: list.insert
  # #   indent: list.dent
  # #   outdent: list.dent
  # SnapEditor.actions.orderedList = list.insert
  # SnapEditor.actions.unorderedList = list.insert
  # SnapEditor.actions.indent = list.dent
  # SnapEditor.actions.outdent = list.dent

  # includeBehaviours = (e) ->
  #   e.api.config.behaviours.push("list")

  # addWhitelistRules = (e) ->
  #   e.api.addWhitelistRule("Unordered List", "ul")
  #   e.api.addWhitelistRule("Ordered List", "ol")
  #   e.api.addWhitelistRule("List Item", "li > List Item")

  # setupList = (e) ->
  #   includeBehaviours(e)
  #   addWhitelistRules(e)

  # $.extend(SnapEditor.buttons,
  #   orderedList: Helpers.createButton("orderedList", "ctrl+shift+8", onInclude: (e) ->
  #     setupList(e)
  #   )
  #   unorderedList: Helpers.createButton("unorderedList", "ctrl+shift+7", onInclude: (e) ->
  #     setupList(e)
  #   )
  #   indent: Helpers.createButton("indent", "", onInclude: includeBehaviours)
  #   outdent: Helpers.createButton("outdent", "", onInclude: includeBehaviours)
  # )

  # SnapEditor.defBehaviour "list",
  #   onActivate: (e) -> $(e.api.el).on("keydown", list.handleTab)
  #   onDeactivate: (e) -> $(e.api.el).off("keydown", list.handleTab)

  # styles = ""
  # for button, i in ["orderedList", "unorderedList", "indent", "outdent"]
  #   styles += Helpers.createStyles(button, (17 + i) * -26) # sprite position * step
  # SnapEditor.insertStyles("plugins_list", styles)

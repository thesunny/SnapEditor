# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  list =
    insert: (e) -> e.api.clean() if e.api["insert#{Helpers.capitalize(e.type)}"]()
    dent: (e) -> e.api.clean() if e.api[e.type]()
    handleTab: (e) ->
      keys = Helpers.keysOf(e)
      if (keys == "tab" or keys == "shift+tab")
        [startItem, endItem] = e.api.getParentElements("li")
        if startItem and endItem
          e.preventDefault()
          e.api.trigger(if keys == "tab" then "indent" else "outdent")
  SnapEditor.actions.orderedList = list.insert
  SnapEditor.actions.unorderedList = list.insert
  SnapEditor.actions.indent = list.dent
  SnapEditor.actions.outdent = list.dent

  includeBehaviours = (e) -> e.api.config.behaviours.push("list")
  $.extend(SnapEditor.buttons,
    orderedList: Helpers.createButton("orderedList", "ctrl+shift+8", onInclude: (e) ->
      includeBehaviours(e)
      e.api.addWhitelistRule("Unordered List", "ul")
      e.api.addWhitelistRule("List Item", "li > List Item")
    )
    unorderedList: Helpers.createButton("unorderedList", "ctrl+shift+7", onInclude: (e) ->
      includeBehaviours(e)
      e.api.addWhitelistRule("Ordered List", "ol")
      e.api.addWhitelistRule("List Item", "li > List Item")
    )
    indent: Helpers.createButton("indent", "", onInclude: includeBehaviours)
    outdent: Helpers.createButton("outdent", "", onInclude: includeBehaviours)
  )

  SnapEditor.behaviours.list =
    onActivate: (e) -> $(e.api.el).on("keydown", list.handleTab)
    onDeactivate: (e) -> $(e.api.el).off("keydown", list.handleTab)

  styles = ""
  for button, i in ["orderedList", "unorderedList", "indent", "outdent"]
    styles += Helpers.createStyles(button, (17 + i) * -26) # sprite position * step
  SnapEditor.insertStyles("plugins_list", styles)

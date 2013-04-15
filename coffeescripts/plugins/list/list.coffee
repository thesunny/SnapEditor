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

  $.extend(SnapEditor.buttons,
    orderedList: Helpers.createButton("orderedList", "ctrl+shift+8", list.insert)
    unorderedList: Helpers.createButton("unorderedList", "ctrl+shift+7", list.insert)
    indent: Helpers.createButton("indent", "", list.dent)
    outdent: Helpers.createButton("outdent", "", list.dent)
  )

  SnapEditor.behaviours.list =
    onActivate: (e) -> $(e.api.el).on("keydown", list.handleTab)
    onDeactivate: (e) -> $(e.api.el).off("keydown", list.handleTab)

  styles = ""
  for button, i in ["orderedList", "unorderedList", "indent", "outdent"]
    styles += Helpers.createStyles(button, (17 + i) * -26) # sprite position * step
  SnapEditor.insertStyles("plugins_list", styles)

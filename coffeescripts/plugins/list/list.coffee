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

  $.extend(SnapEditor.commands,
    orderedList: Helpers.createCommand("orderedList", "ctrl+shift+8", list.insert)
    unorderedList: Helpers.createCommand("unorderedList", "ctrl+shift+7", list.insert)
    indent: Helpers.createCommand("indent", "", list.dent)
    outdent: Helpers.createCommand("outdent", "", list.dent)
  )

  SnapEditor.behaviours.list =
    onActivate: (e) -> $(e.api.el).on("keydown", list.handleTab)
    onDeactivate: (e) -> $(e.api.el).off("keydown", list.handleTab)

  styles = ""
  for command, i in ["orderedList", "unorderedList", "indent", "outdent"]
    styles += Helpers.createStyles(command, (17 + i) * -26) # sprite position * step
  SnapEditor.insertStyles("plugins_list", styles)

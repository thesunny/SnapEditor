define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  window.SnapEditor.internalPlugins.list =
    events:
      activate: (e) ->
        $(e.api.el).on("keydown", e.api.plugins.list.handleTab)
      deactivate: (e) ->
        $(e.api.el).off("keydown", e.api.plugins.list.handleTab)
    commands:
      orderedList: Helpers.createCommand("orderedList", "ctrl.shift.8", (e) -> e.api.plugins.list.insert(e))
      unorderedList: Helpers.createCommand("unorderedList", "ctrl.shift.7", (e) -> e.api.plugins.list.insert(e))
      indent: Helpers.createCommand("indent", "", (e) -> e.api.plugins.list.dent(e))
      outdent: Helpers.createCommand("outdent", "", (e) -> e.api.plugins.list.dent(e))
    insert: (e) -> e.api.clean() if e.api["insert#{Helpers.capitalize(e.type)}"]()
    dent: (e) -> e.api.clean() if e.api[e.type]()
    handleTab: (e) ->
      keys = Helpers.keysOf(e)
      if (keys == "tab" or keys == "shift.tab") 
        [startItem, endItem] = e.api.getParentElements("li")
        if startItem and endItem
          e.preventDefault()
          e.api.trigger(if keys == "tab" then "indent" else "outdent")

  styles = ""
  for command, i in ["orderedList", "unorderedList", "indent", "outdent"]
    styles += Helpers.createStyles(command, (17 + i) * -26) # sprite position * step
  window.SnapEditor.insertStyles("plugins_list", styles)

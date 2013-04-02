define ["jquery.custom"], ($) ->
  window.SnapEditor.internalPlugins.deactivate =
    events:
      pluginsReady: (e) -> $(e.api.el).addClass(e.api.config.plugins.deactivate.classname)
      activate: (e) -> e.api.config.plugins.deactivate.activate(e.api)
      deactivate: (e) -> e.api.config.plugins.deactivate.deactivate(e.api)

    classname: "snapeditor_ignore_deactivate"

    activate: (api) ->
      plugin = api.config.plugins.deactivate
      # mousedown and mouseup are tracked to ensure that the entire click
      # sequence is on an element that triggers the deactivation.
      api.on(
        "snapeditor.document_mousedown": plugin.setDeactivate
        "snapeditor.document_mouseup": plugin.tryDeactivate
      )

    deactivate: (api) ->
      plugin = api.config.plugins.deactivate
      api.off(
        "snapeditor.document_mousedown": plugin.setDeactivate
        "snapeditor.document_mouseup": plugin.tryDeactivate
      )

    setDeactivate: (e) ->
      plugin = e.api.config.plugins.deactivate
      plugin.isDeactivate = true unless plugin.isIgnore(e.target)

    tryDeactivate: (e) ->
      api = e.api
      plugin = api.config.plugins.deactivate
      if plugin.isDeactivate and !plugin.isIgnore(e.target)
        plugin.isDeactivate = false
        api.tryDeactivate()

    isIgnore: (el) ->
      $(el).closest(".#{@classname}").length > 0

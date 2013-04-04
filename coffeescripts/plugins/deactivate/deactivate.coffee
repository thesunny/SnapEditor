define ["jquery.custom"], ($) ->
  window.SnapEditor.internalPlugins.deactivate =
    events:
      pluginsReady: (e) -> $(e.api.el).addClass(e.api.plugins.deactivate.classname)
      activate: (e) -> e.api.plugins.deactivate.activate(e.api)
      deactivate: (e) -> e.api.plugins.deactivate.deactivate()

    classname: "snapeditor_ignore_deactivate"

    activate: (@api) ->
      # mousedown and mouseup are tracked to ensure that the entire click
      # sequence is on an element that triggers the deactivation.
      self = this
      @setDeactivateHandler = (e) -> self.setDeactivate(e)
      @tryDeactivateHandler = (e) -> self.tryDeactivate(e)
      api.on(
        "snapeditor.document_mousedown": @setDeactivateHandler
        "snapeditor.document_mouseup": @tryDeactivateHandler
      )

    deactivate: ->
      @api.off(
        "snapeditor.document_mousedown": @setDeactivateHandler
        "snapeditor.document_mouseup": @tryDeactivateHandler
      )

    setDeactivate: (e) ->
      @isDeactivate = true unless @isIgnore(e.target)

    tryDeactivate: (e) ->
      if @isDeactivate and !@isIgnore(e.target)
        @isDeactivate = false
        @api.tryDeactivate()

    isIgnore: (el) ->
      $(el).closest(".#{@classname}").length > 0

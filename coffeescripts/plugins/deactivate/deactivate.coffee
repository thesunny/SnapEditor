define ["jquery.custom"], ($) ->
  deactivate =
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

  SnapEditor.behaviours.deactivate =
    onPluginsReady: (e) -> $(e.api.el).addClass(deactivate.classname)
    onActivate: (e) -> deactivate.activate(e.api)
    onDeactivate: (e) -> deactivate.deactivate()

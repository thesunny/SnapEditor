define ["jquery.custom"], ($) ->
  class Deactivate
    classname: "snapeditor_ignore_deactivate"

    register: (@api) ->
      $(@api.el).addClass(@classname)
      @api.on("snapeditor.activate", @activate)
      @api.on("snapeditor.deactivate", @deactivate)

    activate: =>
      # mousedown and mouseup are tracked to ensure that the entire click
      # sequence is on an element that triggers the deactivation.
      @api.on(
        "snapeditor.document_mousedown": @setDeactivate
        "snapeditor.document_mouseup": @tryDeactivate
      )

    deactivate: =>
      @api.off(
        "snapeditor.document_mousedown": @setDeactivate
        "snapeditor.document_mouseup": @tryDeactivate
      )

    setDeactivate: (e) =>
      unless @isIgnore(e.target)
        @isDeactivate = true

    tryDeactivate: (e) =>
      if @isDeactivate and !@isIgnore(e.target)
        @isDeactivate = false
        @api.tryDeactivate()

    isIgnore: (el) ->
      $(el).closest(".#{@classname}").length > 0

  return Deactivate

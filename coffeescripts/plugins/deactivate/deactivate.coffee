define ["jquery.custom"], ($) ->
  class Deactivate
    classname: "snapeditor_ignore_deactivate"

    register: (@api) ->
      $(@api.el).addClass(@classname)
      @api.on("activate.editor", @activate)
      @api.on("deactivate.editor", @deactivate)

    activate: =>
      # mousedown and mouseup are tracked to ensure that the entire click
      # sequence is on an element that triggers the deactivation.
      $(document).on("mousedown", @setDeactivate)
      $(document).on("mouseup", @tryDeactivate)

    deactivate: =>
      $(document).off("mousedown", @setDeactivate)
      $(document).off("onmouseup", @tryDeactivate)

    setDeactivate: (e) =>
      unless @isIgnore(e.target)
        @isDeactivate = true

    tryDeactivate: (e) =>
      if @isDeactivate and !@isIgnore(e.target)
        @isDeactivate = false
        @api.deactivate()

    isIgnore: (el) ->
      $(el).closest(".#{@classname}").length > 0

  return Deactivate

# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
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
      @api.trigger("snapeditor.deactivate")

    setDeactivate: (e) ->
      @isDeactivate = true unless @isIgnore(e.target)

    tryDeactivate: (e) ->
      if @isDeactivate and !@isIgnore(e.target)
        @isDeactivate = false
        @api.tryDeactivate()

    isIgnore: (el) ->
      $(el).closest(".#{@classname}").length > 0

  SnapEditor.actions.deactivate = (e) ->
    deactivate.deactivate()

  SnapEditor.behaviours.deactivate =
    onPluginsReady: (e) -> $(e.api.el).addClass(deactivate.classname)
    onActivate: (e) -> deactivate.activate(e.api)

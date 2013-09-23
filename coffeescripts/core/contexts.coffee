# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom"], ($) ->
  class Contexts
    # Arguments:
    # * api - editor API
    # * contexts - array of selectors
    constructor: (@api, @contexts) ->
      @$el = $(@api.el)
      @currentContexts = {}
      @api.on("snapeditor.activate", @activate)
      @api.on("snapeditor.deactivate", @deactivate)

    activate: =>
      @$el.on("keyup", @onkeyup)
      @$el.on("mouseup", @onmouseup)
      @updateContexts()

    deactivate: =>
      @$el.off("keyup", @onkeyup)
      @$el.off("mouseup", @onmouseup)
      @api.trigger("snapeditor.contexts_update", contexts: {}, removed: @contexts)

    onkeyup: (e) =>
      # Key code 13 is 'ENTER'.
      # Key code 33 to 40 are all navigation keys.
      @updateContexts() if e.which == 13 or 33 <= e.which <= 40

    onmouseup: (e) =>
      @updateContexts()

    updateContexts: =>
      matchedContexts = $(@api.getParentElement()).contexts(@contexts, @api.el)
      removedContexts = @getRemovedContexts(matchedContexts)
      @currentContexts = matchedContexts
      @api.trigger("snapeditor.contexts_update", contexts: matchedContexts, removed: removedContexts)

    getRemovedContexts: (matchedContexts) ->
      removedContexts = []
      for context, el of @currentContexts
        removedContexts.push(context) unless matchedContexts[context]
      return removedContexts

  return Contexts

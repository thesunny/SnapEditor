# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom"], ($) ->
  class MirrorInput
    constructor: (source, destination) ->
      @$source = $(source)
      @$destination = $(destination)

    activate: ->
      @shouldMirror = $.trim(@$source.attr("value")) == $.trim(@$destination.attr("value"))
      @$source.on(focus: @startMirroring, blur: @stopMirroring)
      @$destination.on(focus: @startCheckForUserInput, blur: @stopCheckForUserInput)

    deactivate: ->
      @stopMirroring()
      @stopCheckForUserInput()
      @$source.off(focus: @startMirroring, blur: @stopMirroring)
      @$destination.off(focus: @startCheckForUserInput, blur: @stopCheckForUserInput)

    startMirroring: =>
      @mirrorId = setInterval(@mirror, 3) if @shouldMirror

    stopMirroring: =>
      clearInterval(@mirrorId)

    mirror: =>
      @$destination.attr("value", @$source.attr("value"))

    startCheckForUserInput: =>
      @savedDestinationValue = @$destination.attr("value")
      @checkId = setInterval(@checkForUserInput, 3)

    stopCheckForUserInput: =>
      clearInterval(@checkId)

    checkForUserInput: =>
      value = @$destination.attr("value")
      if $.trim(value).length == 0
        # If the user deletes all content, start mirroring.
        @shouldMirror = true
      else if value != @savedDestinationValue
        # If the user changes the value, stop mirroring.
        @shouldMirror = false
        @stopMirroring()

  return MirrorInput

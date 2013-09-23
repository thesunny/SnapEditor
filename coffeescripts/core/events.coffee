# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom"], ($) ->
  return {
    get$eventEl: ->
      @$eventEl or= $("<div/>")

    on: ->
      @get$eventEl().on(arguments...)

    off: ->
      @get$eventEl().off(arguments...)

    trigger: ->
      @get$eventEl().trigger(arguments...)
  }

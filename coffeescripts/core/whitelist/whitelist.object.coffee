define ["jquery.custom"], ($) ->
  class WhitelistObject
    constructor: (@tag, @classes, @next) ->
      @classes = @classes.sort()

    getElement: ->
      $el = $("<#{@tag}>")
      $el.addClass(classname) for classname in @classes
      return $el[0]

  return WhitelistObject

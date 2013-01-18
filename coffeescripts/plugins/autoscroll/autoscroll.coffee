# TODO: Autoscroll is not working right now when you hold down the shift key
# while selecting.
define ["jquery.custom"], ($) ->
  class Autoscroll
    options:
      topMargin: 50
      bottomMargin: 50

    register: (@api) ->
      @api.on("snapeditor.activate", @start)
      @api.on("snapeditor.deactivate", @stop)

    start: =>
      $(@api.el).on("keyup", @autoscroll)

    stop: =>
      $(@api.el).off("keyup", @autoscroll)

    autoscroll: =>
      cursor = @api.getCoordinates()
      scroll = $(@api.win).getScroll()
      winSize = $(@api.win).getSize()
      # The logic here is a little hard to follow but basically, if the scroll
      # is lower than the top line, then we scroll to the top line and if the
      # scroll is higher than the bottom line, then we scroll to the bottom
      # line.
      topLine = cursor.top - @options.topMargin
      bottomLine = cursor.bottom + @options.bottomMargin - winSize.y
      if topLine < scroll.y
        @api.win.scrollTo(scroll.x, topLine)
      else if bottomLine > scroll.y
        @api.win.scrollTo(scroll.x, bottomLine)

  return Autoscroll

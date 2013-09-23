# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# TODO: Autoscroll is not working right now when you hold down the shift key
# while selecting.
define ["jquery.custom"], ($) ->
  autoscroll =
    autoscroll: (e) ->
      if e.api.isValid()
        margins = top: 50, bottom: 50
        api = e.api
        cursor = api.getCoordinates()
        scroll = $(api.win).getScroll()
        winSize = $(api.win).getSize()
        # The logic here is a little hard to follow but basically, if the scroll
        # is lower than the top line, then we scroll to the top line and if the
        # scroll is higher than the bottom line, then we scroll to the bottom
        # line.
        topLine = cursor.top - margins.top
        bottomLine = cursor.bottom + margins.bottom - winSize.y
        if topLine < scroll.y
          api.win.scrollTo(scroll.x, topLine)
        else if bottomLine > scroll.y
          api.win.scrollTo(scroll.x, bottomLine)

  SnapEditor.behaviours.autoscroll =
    onActivate: (e) -> e.api.on("snapeditor.keyup", autoscroll.autoscroll)
    onDeactivate: (e) -> e.api.off("snapeditor.keyup", autoscroll.autoscroll)

  # autoscroll is returned for testing purposes.
  return autoscroll

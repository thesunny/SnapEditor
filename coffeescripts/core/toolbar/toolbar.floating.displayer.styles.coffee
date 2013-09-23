# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/browser"], ($, Browser) ->
  class Styles
    # el is the container that the floater will float around.
    # floater is the thing to be floated around.
    constructor: (el, floater) ->
      @$el = $(el)
      @$floater = $(floater).css("position", "absolute")

    # Returns the styles needed to place the floater at the top of the el.
    top: ->
      if @doesFloaterFit("top")
        styles =
          position: "absolute",
          top: @elCoords().top - @floaterSize().y
      else
        # IE does not display fixed positioning properly so we need to set it as
        # absolutely positioned. Even IE8 is broken when the doctype is not
        # strict. However, this is jittery.
        # In all other browsers, fixed positioning is supported.
        styles = @topFixed()
      $.extend(styles, @x())

    # Returns the styles needed to place the floater at the bottom of the el.
    bottom: ->
      if @doesFloaterFit("bottom")
        styles =
          position: "absolute",
          top: @elCoords().bottom
      else
        # IE does not display fixed positioning properly so we need to set it as
        # absolutely positioned. Even IE8 is broken when the doctype is not
        # strict. However, this is jittery.
        # In all other browsers, fixed positioning is supported.
        styles = @bottomFixed()
      $.extend(styles, @x())

    elCoords: ->
      @$el.getCoordinates()

    floaterSize: ->
      @$floater.getSize(true, true)

    # Returns the styles needed to center the floater relative to the el.
    # This ensures that the floater will not show up outside of the window.
    x: ->
      floaterSize = @floaterSize()
      windowSize = $(window).getSize()
      floaterLeft = @elCoords().left

      # This ensures the floater does not show up outside of the window to the
      # left or the right.
      if floaterLeft < 0
        floaterLeft = 0
      else if floaterLeft + floaterSize.x > windowSize.x
        floaterLeft = windowSize.x - floaterSize.x
      left: floaterLeft

    # where can be "top" or "bottom" 
    # Returns the distance of:
    # "top": top of the el to the top of the window
    # "bottom": bottom of the el to the bottom of the window
    spaceBetweenElAndWindow: (where) ->
      elCoords = @elCoords()
      windowScroll = $(window).getScroll()

      space = 0
      if where == "top"
        space = elCoords.top - windowScroll.y
      else
        space = windowScroll.y + $(window).getSize().y - elCoords.bottom
      space

    # where can be "top" or "bottom" 
    # Returns true if the floater fits between the el and the window.
    doesFloaterFit: (where) ->
      @spaceBetweenElAndWindow(where) >= @floaterSize().y

    # Get the styles for fixing the floater at the top of the window.
    #
    # NOTE: IE does not support fixed positioning properly. Therefore, it is
    # fixed by absolutely positioning it. This causes some jittering though.
    topFixed: ->
      if Browser.isIE
        position: "absolute",
        top: $(window).getScroll().y
      else
        position: "fixed",
        top: 0

    # Get the styles for fixing the floater at the bottom of the window.
    #
    # NOTE: IE does not support fixed positioning properly. Therefore, it is
    # fixed by absolutely positioning it. This causes some jittering though.
    bottomFixed: ->
      if Browser.isIE
        position: "absolute",
        top: $(window).getScroll().y + $(window).getSize().y - @floaterSize().y
      else
        position: "fixed",
        top: $(window).getSize().y - @floaterSize().y

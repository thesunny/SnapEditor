# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/toolbar/toolbar.floating.displayer.styles", "core/browser"], ($, Styles, Browser) ->
  class Displayer
    constructor: (toolbar, el, @editor) ->
      @$toolbar = $(toolbar)
      @$el = $(el)
      @shown = false
      @positionedAtTop = true
      # Insert the toolbar into the DOM and make sure it's hidden.
      @$toolbar.hide().appendTo("body")

    getHeight: ->
      parseInt(@$toolbar.css('height'))

    setup: ->
      @styles = new Styles(@$el, @$toolbar)
      $(window).on("scroll resize", @updateWithoutCursorCheck)
      @$el.on("mouseup keyup", @updateWithCursorCheck)

    teardown: ->
      $(window).off("scroll resize", @updateWithoutCursorCheck)
      @$el.off("mouseup keyup", @updateWithCursorCheck)

    # Shows the toolbar.
    show: =>
      unless @shown
        @setup()
        @$toolbar.show()
        @shown = true
        @updateWithCursorCheck()

    # Hides the toolbar.
    hide: =>
      if @shown
        @$toolbar.hide()
        @shown = false
        @teardown()

    # Places the toolbar in the proper position.
    # First, it repositions the toolbar in its current orientation to account
    # for editor height changes or scrolling. Then, it checks to see if it
    # needs to move the orientation to the top or bottom of the el depending
    # on whether or not it will cover the cursor.
    update: (checkCursor) =>
      if @shown
        if @positionedAtTop
          @positionAtTop()
          @moveToBottom() if checkCursor and @isCursorInOverlapSpace()
        else
          @positionAtBottom()
          @moveToTop() if checkCursor and !@isCursorInOverlapSpace()

    updateWithoutCursorCheck: =>
      @update(false)

    updateWithCursorCheck: =>
      @update(true)

    elCoords: ->
      @$el.getCoordinates()

    toolbarSize: ->
      @$toolbar.getSize()

    # Grabs the position of the top of the cursor.
    cursorPosition: ->
      @editor.getCoordinates().top

    # Place the toolbar at the top of the el 
    positionAtTop: ->
      @positionedAtTop = true
      @$toolbar.css(@styles.top())

    # Place the toolbar at the bottom of the el. 
    positionAtBottom: ->
      @positionedAtTop = false
      @$toolbar.css(@styles.bottom())

    # Slide the toolbar to the top of the el 
    moveToTop: ->
      @positionedAtTop = true
      @animate(@styles.top())

    # Slide the toolbar to the bottom of the el 
    moveToBottom: ->
      @positionedAtTop = false
      @animate(@styles.bottom())

    animate: (styles) ->
      # jQuery does not handle "position" in animate() very well in IE7/8. It
      # will sometimes throw an error. Hence, we rip out position and set it
      # after the animation is done.
      if Browser.isIE7 or Browser.isIE8
        position = styles.position
        delete styles.position
        completeFn = -> $(this).css("position", position)
      @$toolbar.animate(styles, duration: 'fast', complete: completeFn)

    # In certain scenarios, it is possible for the toolbar to overlap the el at the
    # top.
    # Returns the amount of overlap space inside the el.
    overlapSpaceFromElTop: ->
      elCoords = @elCoords()
      overlap = @toolbarSize().y - elCoords.top
      if overlap > 0 then overlap else 0

    # In certain scenarios, it is possible for the toolbar to overlap the el at the
    # top.
    # Returns true if the cursor is in this space.
    isCursorInOverlapSpace: ->
      return false unless @editor.isValid()
      cursorPositionInEl = @cursorPosition() - @elCoords().top
      cursorPositionInEl < @overlapSpaceFromElTop()

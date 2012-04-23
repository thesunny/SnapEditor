define ["jquery.custom", "plugins/toolbar/toolbar.floating.displayer.styles"], ($, Styles) ->
  class Displayer
    constructor: (toolbar, el, @api) ->
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
      $(window).on("scroll resize", @update)
      @$el.on("mouseup keyup", @updateAndCheckCursor)

    teardown: ->
      $(window).off("scroll resize", @update)
      @$el.off("mouseup keyup", @updateAndCheckCursor)

    # Shows the toolbar.
    show: =>
      unless @shown
        @setup()
        @$toolbar.show()
        @shown = true
        @updateAndCheckCursor()

    # Hides the toolbar.
    hide: =>
      if @shown
        @$toolbar.hide()
        @shown = false
        @teardown()

    # Places the toolbar in the proper position.
    # First, it repositions the toolbar in its current orientation to account for
    # editor height changes or scrolling. Then, it checks to see if it needs to
    # move the orientation to the top or bottom of the el depending on whether
    # or not it will cover the cursor.
    update: (checkCursor) =>
      if @shown
        if @positionedAtTop
          @positionAtTop()
          @moveToBottom() if checkCursor and @isCursorInOverlapSpace()
        else
          @positionAtBottom()
          @moveToTop() if checkCursor and !@isCursorInOverlapSpace()

    updateAndCheckCursor: =>
      @update(true)

    elCoords: ->
      @$el.getCoordinates()

    toolbarSize: ->
      @$toolbar.getSize()

    # Grabs the position of the top of the cursor.
    cursorPosition: ->
      @api.getCoordinates().top

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
      @$toolbar.animate(@styles.top(), duration: 'fast')

    # Slide the toolbar to the bottom of the el 
    moveToBottom: ->
      @positionedAtTop = false
      @$toolbar.animate(@styles.bottom(), duration: 'fast')

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
      cursorPositionInEl = @cursorPosition() - @elCoords().top
      cursorPositionInEl < @overlapSpaceFromElTop()

  return Displayer

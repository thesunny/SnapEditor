define ["jquery.custom"], ($) ->
  window.SnapEditor.internalPlugins.snap =
    events:
      activate: (e) -> e.api.config.plugins.snap.snap(e.api) if e.api.config.snap
      deactivate: (e) -> e.api.config.plugins.snap.unsnap() if e.api.config.snap
      cleanerFinished: (e) -> e.api.config.plugins.snap.update() if e.api.config.snap

    # Start the snap.
    snap: (api) ->
      @activated = true
      @api = api
      @$el = $(@api.el)
      @setup() unless @divs
      div.show() for position, div of @divs
      options = @getFxOptions()
      div.css(options.unsnapped[position]) for position, div of @divs
      div.animate(options.snapped[position], duration: "fast") for position, div of @divs
      @api.on(
        "snapeditor.keyup": @update
        "snapeditor.mouseup": @update
      )
      self = this
      @resizeHandler = -> self.update()
      $(window).on("resize", @resizeHandler)

    # Start the unsnap.
    unsnap: ->
      if @activated
        options = @getFxOptions()
        div.css(options.snapped[position]) for position, div of @divs
        div.animate(options.unsnapped[position], duration: "fast", complete: -> $(this).hide()) for position, div of @divs
        @api.off(
          "snapeditor.keyup": @update
          "snapeditor.mouseup": @update
        )
        $(window).off("resize", @resizeHandler)
        @active = false

    # Updates the divs in case @$el changed dimensions.
    update: ->
      if @activated
        elCoord = @getElCoordinates()
        documentSize = $(document).getSize()
        styles = @getSnappedStyles(elCoord, documentSize)
        div.css(styles[position]) for position, div of @divs

    # Prepare the semi-transparent divs and the snap/unsnap effects.
    setup: ->
      # Create the template snap div.
      div = $("<div/>").css(
        opacity: 0.2
        position: 'absolute'
        background: 'black'
        top: 0
        left: 0
        zIndex: 100
      )
      @divs =
        top: div.clone(true, false).appendTo("body")
        bottom: div.clone(true, false).appendTo("body")
        left: div.clone(true, false).appendTo("body")
        right: div.clone(true, false).appendTo("body")

    # Get the styles of all the divs after they have been snapped. The divs
    # should surround the el.
    # |     |  top  |       |
    # |     |_______|       |
    # |     |       |       |
    # |left |  el   | right |
    # |     |       |       |
    # |     |_______|       |
    # |     |bottom |       |
    # |     |       |       |
    getSnappedStyles: (elCoords, documentSize) ->
      return {
        top:
          left: elCoords.left
          width: elCoords.width
          height: elCoords.top
        bottom:
          top: elCoords.bottom
          left: elCoords.left
          width: elCoords.width
          height: documentSize.y - elCoords.bottom
        left:
          width: elCoords.left
          height: documentSize.y
        right:
          left: elCoords.right
          width: documentSize.x - elCoords.right
          height: documentSize.y
      }

    # Get the styles of all the divs when they are unsnapped. The divs should
    # surround the viewport.
    # |     |  top         |        |
    # |     |______________|        |
    # |     |              |        |
    # |left |  viewport    |  right |
    # |     |   ___________|_       |
    # |     |   |          | |      |
    # |     |   | el       | |      |
    # |     |   |__________|_|      |
    # |     |              |        |
    # |     |______________|        |
    # |     |bottom        |        |
    # |     |              |        |
    getUnsnappedStyles: (documentSize, portCoords) ->
      return {
        top:
          left: portCoords.left
          width: portCoords.width
          height: portCoords.top
        bottom:
          top: portCoords.bottom
          left: portCoords.left
          width: portCoords.width
          height: documentSize.y - portCoords.bottom
        left:
          width: portCoords.left
          height: documentSize.y
        right:
          left: portCoords.right
          width: documentSize.x - portCoords.right
          height: documentSize.y
      }

    # Returns the coordinates of the current viewport.
    getPortCoordinates: ->
      winScroll = $(window).getScroll()
      winSize = $(window).getSize()
      return {
        top: winScroll.y
        bottom: winScroll.y + winSize.y
        left: winScroll.x
        right: winScroll.x + winSize.x
        width: winSize.x
        height: winSize.y
      }

    # Returns an objec that contains the snapped and unsnapped styles of all the
    # divs.
    getFxOptions: ->
      elCoords = @getElCoordinates()
      documentSize = $(document).getSize()
      portCoords = @getPortCoordinates()
      return {
        snapped: @getSnappedStyles(elCoords, documentSize)
        unsnapped: @getUnsnappedStyles(documentSize, portCoords)
      }

    # Grab the coordinates of the element.
    getElCoordinates: ->
      elCoord = @$el.getCoordinates()
      padding = @$el.getPadding()
      # NOTE: The top and left coordinates are calculated correctly when there
      # is padding. However, the other coordinates must be adjusted.
      elCoord.bottom += padding.top + padding.bottom
      elCoord.right += padding.left + padding.right
      elCoord.width += padding.left + padding.right
      elCoord.height += padding.top + padding.bottom
      return elCoord

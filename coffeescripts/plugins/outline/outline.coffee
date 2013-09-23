# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom"], ($) ->
  outline =
    setup: (api) ->
      self = this
      el = api.el
      showHandler = (e) ->
        self.show(el) if api.isEnabled()
      hideHandler = (e) ->
        self.hide()
      api.on(
        "snapeditor.activate": ->
          self.hide()
          $(el).off(mouseover: showHandler, mouseout: hideHandler)
        "snapeditor.deactivate": ->
          # Listen to the el directly because at this point, SnapEditor is not
          # activated and will not trigger events.
          $(el).on(mouseover: showHandler, mouseout: hideHandler)
      )
      $(el).on(mouseover: showHandler, mouseout: hideHandler)

    show: (el) ->
      @setupOutlines()
      @update(el)
      @outlines.top.show()
      @outlines.bottom.show()
      @outlines.left.show()
      @outlines.right.show()
      self = this
      @resizeHandler = -> self.update(el)
      $(window).on("resize", @resizeHandler)
      @shown = true

    hide: ->
      if @shown
        @outlines.top.hide()
        @outlines.bottom.hide()
        @outlines.left.hide()
        @outlines.right.hide()
        $(window).off("resize", @resizeHandler)
        @shown = false

    update: (el) ->
      styles = @getStyles(el)
      @outlines.top.css(styles.top)
      @outlines.bottom.css(styles.bottom)
      @outlines.left.css(styles.left)
      @outlines.right.css(styles.right)

    setupOutlines: ->
      unless @outlines
        $div = $("<div/>").css(
          position: "absolute"
          width: 0
          height: 0
          "border-style": "dashed"
          "border-color": "#5c5c5c"
          "border-width": 0
        )
        @outlines =
          top: $div.clone().css("border-bottom-width", 1).appendTo("body")
          bottom: $div.clone().css("border-top-width", 1).appendTo("body")
          left: $div.clone().css("border-right-width", 1).appendTo("body")
          right: $div.clone().css("border-left-width", 1).appendTo("body")

    getElCoordinates: (el) ->
      coords = $(el).getCoordinates()
      padding = $(el).getPadding()
      coords.bottom += padding.top + padding.bottom
      coords.right += padding.left + padding.right
      coords.width += padding.left + padding.right
      coords.height += padding.top + padding.bottom
      return coords

    getStyles: (el) ->
      coords = @getElCoordinates(el)
      return {
        top:
          top: coords.top - 1
          left: coords.left - 1
          width: coords.width + 2
        bottom:
          top: coords.top + coords.height + 1
          left: coords.left - 1
          width: coords.width + 2
        left:
          top: coords.top - 1
          left: coords.left - 1
          height: coords.height + 2
        right:
          top: coords.top - 1
          left: coords.left + coords.width + 1
          height: coords.height + 2
      }

  SnapEditor.behaviours.outline =
    onPluginsReady: (e) -> outline.setup(e.api)

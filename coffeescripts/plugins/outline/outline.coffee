define ["jquery.custom"], ($) ->
  window.SnapEditor.internalPlugins.outline =
    events:
      pluginsReady: (e) -> e.api.config.plugins.outline.activate(e.api)
      activate: (e) -> e.api.config.plugins.outline.deactivate()
      deactivate: (e) -> e.api.config.plugins.outline.activate(e.api)

    activate: (api) ->
      @api = api
      @$el = $(@api.el)
      self = this
      @showHandler = -> self.show()
      @hideHandler = -> self.hide()
      @$el.on(mouseover: @showHandler, mouseout: @hideHandler)

    deactivate: ->
      @hide()
      self = this
      @$el.off(mouseover: @showHandler, mouseout: @hideHandler)

    show: ->
      @setupOutlines()
      @update()
      @outlines.top.show()
      @outlines.bottom.show()
      @outlines.left.show()
      @outlines.right.show()
      self = this
      @resizeHandler = -> self.update()
      $(window).on("resize", @resizeHandler)

    hide: ->
      @outlines.top.hide()
      @outlines.bottom.hide()
      @outlines.left.hide()
      @outlines.right.hide()
      $(window).off("resize", @resizeHandler)

    update: ->
      styles = @getStyles()
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

    getElCoordinates: ->
      coords = @$el.getCoordinates()
      padding = @$el.getPadding()
      coords.bottom += padding.top + padding.bottom
      coords.right += padding.left + padding.right
      coords.width += padding.left + padding.right
      coords.height += padding.top + padding.bottom
      return coords

    getStyles: ->
      coords = @getElCoordinates()
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

define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  class Atomic
    register: (@api) ->
      @classname = @api.config.atomic.classname
      @api.on("activate.editor", @activate)
      @api.on("deactivate.editor", @deactivate)
      @api.on("ready.editor", @mouseup)

    activate: =>
      $(@api.el).on(
        keyup: @keyup
        mouseup: @mouseup
      )

    deactivate: =>
      $(@api.el).off(
        keyup: @keyup
        mouseup: @mouseup
      )

    forwardKeys: ["right", "down", "pagedown", "end"]
    backwardKeys: ["left", "up", "pageup", "home"]

    keyup: (e) =>
      key = Helpers.keyOf(e)
      if $.inArray(key, @forwardKeys) != -1
        direction = "forward"
      else if $.inArray(key, @backwardKeys) != -1
        direction = "backward"
      @handleRange(direction) if direction

    mouseup: (e) =>
      @handleRange("mouse")

    # Arugments:
    # * direction - forward/backward/mouse
    handleRange: (direction) ->
      [startParent, endParent] = @api.getParentElements(".#{@classname}")
      if @api.isCollapsed() and startParent
        @moveCollapsedRange(startParent, direction)
      else if startParent or endParent
        @moveSelectedRange(startParent, endParent, direction)
      @api.clean()
      @api.update()

    # Returns the previous/next sibling of el.
    #
    # Arguments:
    # which - previous/next
    # el - relative to this element
    getSibling: (which, el) ->
      sibling = el["#{which}Sibling"]
      # If the sibling doesn't exist or it is an atomic element, then we
      # insert a new sibling.
      if !sibling or $(sibling).hasClass(@classname)
        position = if which == "previous" then "before" else "after"
        sibling = @insertSibling(position, el)
      sibling

    # If el is a block element, inserts the default block before/after the
    # element.
    # If el is an inline element, inserts a zero width no-break space
    # before/after the element.
    # Returns the inserted sibling.
    #
    # Arguments:
    # position - before/after
    # el - insert relative to this element
    insertSibling: (position, el) ->
      if Helpers.isBlock(el)
        sibling = $(@api.getDefaultBlock()).html(Helpers.zeroWidthNoBreakSpace)[0]
      else
        sibling = @api.createTextNode(Helpers.zeroWidthNoBreakSpaceUnicode)
      $(el)[position](sibling)
      sibling

    # Arguments:
    # * el - move the range relative to this el
    # * direction - forward/backward/mouse
    moveCollapsedRange: (el, direction) ->
      range = @api.getRange()
      switch direction
        when "forward", "mouse"
          next = @getSibling("next", el)
          range.moveBoundary("EndToStart", @getSibling("next", el))
          range.collapse(false)
        when "backward"
          range.moveBoundary("StartToEnd", @getSibling("previous", el))
          range.collapse(true)
      range.select()

    moveSelectedRange: (startEl, endEl, direction) ->
      if startEl or endEl
        range = @api.getRange()
        switch direction
          when "forward"
            range.moveBoundary("StartToStart", @getSibling("next", startEl)) if startEl
            range.moveBoundary("EndToStart", @getSibling("next", endEl)) if endEl
          when "backward"
            range.moveBoundary("StartToEnd", @getSibling("previous", startEl)) if startEl
            range.moveBoundary("EndToEnd", @getSibling("previous", endEl)) if endEl
          when "mouse"
            range.moveBoundary("StartToEnd", @getSibling("previous", startEl)) if startEl
            range.moveBoundary("EndToStart", @getSibling("next", endEl)) if endEl
        range.select()

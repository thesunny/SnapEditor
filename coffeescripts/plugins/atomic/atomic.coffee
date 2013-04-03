define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  window.SnapEditor.internalPlugins.atomic =
    events:
      activate: (e) -> e.api.config.plugins.atomic.activate(e.api)
      deactivate: (e) -> e.api.config.plugins.atomic.deactivate(e.api)
      ready: (e) -> e.api.config.plugins.atomic.mouseup(e)

    activate: (api) ->
      api.on(
        "snapeditor.keyup": @keyup
        "snapeditor.mouseup": @mouseup
      )

    deactivate: (api) ->
      api.off(
        "snapeditor.keyup": @keyup
        "snapeditor.mouseup": @mouseup
      )

    # Backspace is considered a forward key because when we backspace into an
    # atomic element, we want to push the cursor forward so it stays at the
    # end of the atomic element. The same reasoning is used for delete.
    forwardKeys: ["right", "down", "pagedown", "end", "backspace"]
    backwardKeys: ["left", "up", "pageup", "home", "delete"]

    keyup: (e) ->
      api = e.api
      plugin = api.config.plugins.atomic
      key = Helpers.keyOf(e)
      if $.inArray(key, plugin.forwardKeys) != -1
        direction = "forward"
      else if $.inArray(key, plugin.backwardKeys) != -1
        direction = "backward"
      plugin.handleRange(api, direction) if direction

    mouseup: (e) ->
      e.api.config.plugins.atomic.handleRange(e.api, "mouse")

    getCSSelectors: (api) ->
      ["hr"].concat(api.config.atomic.selectors).join(",")

    # Arugments:
    # * direction - forward/backward/mouse
    handleRange: (api, direction) ->
      [startParent, endParent] = api.getParentElements(@getCSSelectors(api))
      # Only do something if the range is inside an atomic element.
      if startParent or endParent
        if api.isCollapsed() and startParent
          @moveCollapsedRange(api, startParent, direction)
        else if startParent or endParent
          @moveSelectedRange(api, startParent, endParent, direction)
        api.clean()

    isAtomic: (api, node) ->
      Helpers.isElement(node) and $(node).filter(@getCSSelectors(api)).length > 0

    # Returns the previous/next sibling of el.
    #
    # Arguments:
    # which - previous/next
    # el - relative to this element
    getSibling: (api, which, el) ->
      sibling = el["#{which}Sibling"]
      # If the sibling doesn't exist or it is an atomic element, then we
      # insert a new sibling.
      if !sibling or @isAtomic(api, sibling)
        position = if which == "previous" then "before" else "after"
        sibling = @insertSibling(api, position, el)
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
    insertSibling: (api, position, el) ->
      if Helpers.isBlock(el)
        sibling = $(api.getDefaultBlock()).html(Helpers.zeroWidthNoBreakSpace)[0]
      else
        sibling = api.createTextNode(Helpers.zeroWidthNoBreakSpaceUnicode)
      $(el)[position](sibling)
      sibling

    # Arguments:
    # * el - move the range relative to this el
    # * direction - forward/backward/mouse
    moveCollapsedRange: (api, el, direction) ->
      range = api.getRange()
      switch direction
        when "forward", "mouse"
          next = @getSibling(api, "next", el)
          range.moveBoundary("EndToStart", @getSibling(api, "next", el))
          range.collapse(false)
        when "backward"
          range.moveBoundary("StartToEnd", @getSibling(api, "previous", el))
          range.collapse(true)
      range.select()

    moveSelectedRange: (api, startEl, endEl, direction) ->
      if startEl or endEl
        range = api.getRange()
        switch direction
          when "forward"
            range.moveBoundary("StartToStart", @getSibling(api, "next", startEl)) if startEl
            range.moveBoundary("EndToStart", @getSibling(api, "next", endEl)) if endEl
          when "backward"
            range.moveBoundary("StartToEnd", @getSibling(api, "previous", startEl)) if startEl
            range.moveBoundary("EndToEnd", @getSibling(api, "previous", endEl)) if endEl
          when "mouse"
            range.moveBoundary("StartToEnd", @getSibling(api, "previous", startEl)) if startEl
            range.moveBoundary("EndToStart", @getSibling(api, "next", endEl)) if endEl
        range.select()

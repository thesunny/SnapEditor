define ["jquery.custom"], ($) ->
  class Cleaner
    register: (@api) ->
      @$el = $(@api.el)
      @api.on("activate.editor", => @start(false))
      @start(false)

    start: (saveRange) =>
      childNodes = @getChildNodesAsArray()
      # If there are no children, insert an empty <p>.
      if childNodes.length == 0
        $p = $("<p><br/></p>")
        $p.prepend($('<span id="CLEAN_CURSOR"></span>')) if saveRange
        @$el.prepend($p)
      else
        # Save the range position because if we move anything around,
        # the current range will be destroyed.
        @saveRangePosition() if saveRange
        @cleanup()
      @positionSavedRange() if saveRange

    cleanup: ->
      childNodes = @getChildNodesAsArray()
      # nodeType 1 is an Element
      # nodeType 3 is a text node
      # Collect up all consecutive inline nodes and wrap them in a <p>.
      lastEl = null
      inlineNodes = []
      for node in childNodes
        type = node.nodeType
        # Textnode or inline element.
        if type == 3 or (type == 1 and $(node).css('display') == 'inline')
          inlineNodes.push(node)
        else
          @wrapInlineNodes(inlineNodes, lastEl)
          inlineNodes = []
          lastEl = $(node)
      # Wrap any remaining inline nodes.
      @wrapInlineNodes(inlineNodes, lastEl)

    getChildNodesAsArray: ->
      childNodes = @$el[0].childNodes
      childNodesLength = childNodes.length
      array = []
      # Keep only elements and non-empty textnodes.
      for node in childNodes
        nodeType = node.nodeType
        if nodeType == 1 or nodeType == 3 and node.data.trim() != ''
          array.push(node)
      array

    wrapInlineNodes: (inlineNodes, lastEl) ->
      if inlineNodes.length > 0
        p = $('<p>').append(inlineNodes)
        # if there is no lastEl, then we know we are at the top so we
        # inject at the top of the div.
        if lastEl
          $(lastEl).after(p)
        else
          @$el.prepend(p)

    saveRangePosition: ->
      # Save the cursor. The range will be destroyed if we move
      # anything around. Therefore, we set a span to remember where
      # the cursor is.
      @api.collapse()
      @api.paste('<span id="CLEAN_CURSOR"></span>')

    positionSavedRange: ->
      $span = $("#CLEAN_CURSOR")
      range = @api.range($span[0])
      range.select()
      $span.remove()

  return Cleaner

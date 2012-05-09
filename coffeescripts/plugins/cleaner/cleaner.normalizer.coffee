define ["jquery.custom", "core/helpers", "plugins/cleaner/cleaner.flattener"], ($, Helpers, Flattener) ->
  class Normalizer
    doNotUseAsTemplate: ["ol", "ul", "li", "table", "tbody", "thead", "tfoot", "tr", "th", "td", "caption", "colgroup", "col"]

    constructor: (@api) ->
      @flattener = new Flattener()

    # Normalizes all the nodes between and including startNode and endNode.
    # All elements will be checked against the whitelist and replaced if needed.
    # All contiguous inline top nodes will be wrapped in a block.
    # All top blocks will be flattened.
    normalize: (startNode, endNode) ->
      # If no block was found, wrap all the children in a block.
      unless @normalizeNodes(startNode, endNode)
        inlineNodes = []
        node = startNode
        while node != endNode
          inlineNodes.push(node)
          node = node.nextSibling
        inlineNodes.push(endNode)
        @blockify(inlineNodes, null)

    # It is expected that the startNode and endNode have the same parent.
    # If all the nodes are inline nodes, this does nothing.
    # If there are any blocks, it wraps all inline nodes in a block.
    # It then goes and normalizes those blocks. If there are any nested blocks,
    # it flattens them.
    # Returns true if there are any blocks. False otherwise.
    normalizeNodes: (startNode, endNode) ->
      blockFound = false
      if startNode and endNode
        inlineNodes = []
        node = startNode
        # Loop through all the nodes between and including startNode and
        # endNode.
        loop
          # Check the stop condition first because the node may be removed.
          stop = node == endNode
          nextSibling = node.nextSibling
          node = @checkWhitelist(node)
          # Blockify any previous inline nodes and normalize and flatten the
          # block.
          if Helpers.isBlock(node)
            blockFound = true
            @blockify(inlineNodes, node)
            inlineNodes = []
            # If blocks were found, flatten them.
            if @normalizeNodes(node.firstChild, node.lastChild)
              @flattener.flatten(node)
          else
            inlineNodes.push(node)
          # If we are at the endNode, finish up, then break out of the loop.
          break if stop
          node = nextSibling
        # If a block was found, blockify the rest of the inline nodes.
        @blockify(inlineNodes, null) if blockFound
      return blockFound

    # Wraps the inline nodes in a block using the parent as a template and
    # places the block before the reference node.
    # If there are no inline nodes, nothing happens.
    # If the parent is the editor, it uses the default block as the template.
    # If the reference node is null, places the block at the end.
    blockify: (inlineNodes, refNode) ->
      if inlineNodes.length > 0
        $parent = $(inlineNodes[0].parentNode)
        # Create the wrapper block.
        if $parent[0] == @api.el or $.inArray($parent.tagName(), @doNotUseAsTemplate) != -1
          $block = $(@api.defaultBlock())
        else
          $block = $("<#{$parent.tagName()}/>")
          $block.attr("class", $parent.attr("class"))
        $block.append(inlineNodes)
        # Place the block in the proper position unless it consists of all
        # whitespaces.
        $parent[0].insertBefore($block[0], refNode) unless $block.html().match(/^\s*$/)

    # TODO: Check whitelist for inline nodes too.
    # Checks the node against the whitelist.
    # If the node is an inline node, returns the inline node.
    # If the node is an element and is on the whitelist, return the node.
    # If the node is an element and is not on the whitelist, replace the node
    # and return it.
    checkWhitelist: (node) ->
      return node unless Helpers.isBlock(node)
      return node if @api.allowed(node)
      $replacement = $(@api.replacement(node)).append(node.childNodes)
      $(node).replaceWith($replacement)
      return $replacement[0]

  return Normalizer

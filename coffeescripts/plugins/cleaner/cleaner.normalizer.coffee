define ["jquery.custom", "core/helpers", "plugins/cleaner/cleaner.flattener"], ($, Helpers, Flattener) ->
  class Normalizer
    doNotUseAsTemplate: ["ol", "ul", "li", "table", "tbody", "thead", "tfoot", "tr", "th", "td", "caption", "colgroup", "col"]

    constructor: (@api) ->
      @flattener = new Flattener()

    # Normalizes all the nodes between and including startNode and endNode.
    # Assumes startNode and endNode have the same parent.
    # All elements will be checked against the whitelist and replaced if needed.
    # All contiguous inline top nodes will be wrapped in a block.
    # All top blocks will be flattened.
    normalize: (startNode, endNode) ->
      # Gather the nodes before normalizing as the start and end nodes may be
      # removed/replaced.
      parentNode = startNode.parentNode
      prevNode = startNode.previousSibling
      nextNode = endNode.nextSibling
      # If no block was found, wrap all the children in a block.
      unless @normalizeNodes(startNode, endNode)
        inlineNodes = []
        newStartNode = (prevNode and prevNode.nextSibling) or parentNode.firstChild
        newEndNode = (nextNode and nextNode.previousSibling) or parentNode.lastChild
        node = newStartNode
        loop
          inlineNodes.push(node)
          break if node == newEndNode
          node = node.nextSibling
        @blockify(inlineNodes, nextNode)

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
          # Grab all relevant info first because the node may be removed.
          stop = node == endNode
          nextSibling = node.nextSibling

          # Handle whitelisting of the node first.
          replacement = @checkWhitelist(node)
          # If the node has been replaced, use the replacement.
          node = replacement if replacement

          isBlock = Helpers.isBlock(node)
          if isBlock
            # Blockify any previous inline nodes.
            blockFound = true
            @blockify(inlineNodes, node)
            inlineNodes = []

          if Helpers.isElement(node)
            # Normalize the children first.
            innerBlockFound = @normalizeNodes(node.firstChild, node.lastChild)
            if isBlock and !innerBlockFound and !replacement and node.firstChild
              # If there are children and all the children are inline nodes
              # and no replacement was found for the block, we cannot just
              # flatten the outer block as this would cause dangling inline
              # nodes. Hence, we replace the outer block with the default block.
              $(node).replaceElementWith(@api.defaultBlock())
            else if innerBlockFound or !replacement
              # If inner blocks were found or there is no replacement, flatten
              # the outer element.

              # The first and last children may have changed after the call to
              # @normalizeNodes. Hence, we grab them here instead of earlier in
              # the loop.
              # We need to grab them before the node is flattened or we'll lose
              # the children.
              firstChild = node.firstChild
              lastChild = node.lastChild
              @flattener.flatten(node)
              # If the node was inline, take all of its children and add them to
              # the inline nodes.
              unless isBlock
                inlineNodes = inlineNodes.concat(Helpers.nodesFrom(firstChild, lastChild))
            else if !isBlock
              # If the node is inline, no blocks were found, and a replacement
              # was found, add the node to the inline nodes.
              inlineNodes.push(node)
          else
            # If the node is a textnode, add it to the inline nodes.
            inlineNodes.push(node)

          # If we are at the endNode break out of the loop.
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
          $block = $(@api.createElement($parent.tagName()))
          $block.attr("class", $parent.attr("class"))
        $block.append(inlineNodes)
        # Place the block in the proper position unless it consists of all
        # whitespaces.
        $parent[0].insertBefore($block[0], refNode) unless $block.html().match(/^\s*$/)

    # Checks the node against the whitelist.
    # If the node is a textnode, returns the textnode.
    # If the node is an element and is on the whitelist, return the node.
    # If the node is a not on the whitelist and a replacement can be found,
    # replace the node with the replacement and return it.
    # Otherwise, return null.
    checkWhitelist: (node) ->
      return node unless Helpers.isElement(node)
      return node if @api.allowed(node)
      return null if @blacklisted(node)
      replacement = @api.replacement(node)
      $(node).replaceElementWith(replacement) if replacement
      return replacement

    blacklisted: (node) ->
      return false unless Helpers.isElement(node)
      blacklisted = false
      $el = $(node)
      switch $el.tagName()
        when "br" then blacklisted = $el.hasClass("Apple-interchange-newline")
        when "span" then blacklisted = $el.hasClass("Apple-style-span") or $el.hasClass("Apple-tab-span")
      return blacklisted

  return Normalizer

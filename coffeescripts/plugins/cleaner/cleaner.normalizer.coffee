define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  class Normalizer
    doNotFlatten: ["ol", "ul", "li"]
    doNotUseAsTemplate: ["ol", "ul", "li"]

    constructor: (@api) ->

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
          nextSibling = node.nextSibling
          node = @checkWhitelist(node)
          # Blockify any previous inline nodes and normalize and flatten the
          # block.
          if Helpers.isBlock(node)
            blockFound = true
            @blockify(inlineNodes, node)
            inlineNodes = []
            # If blocks were found, flatten them unless the node is in the do
            # not flatten list.
            if @normalizeNodes(node.firstChild, node.lastChild)
              @flattenBlock(node)
          else
            inlineNodes.push(node)
          # If we are at the endNode, finish up, then break out of the loop.
          if node == endNode
            break
          else
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
        # Figure out the template.
        if $parent[0] == @api.el or @doNotUseAsTemplate.indexOf($parent.tagName()) != -1
          template = @api.defaultBlock()
        else
          template =
            tag: $parent.tagName()
            classes: ($parent.attr("class") or "").split(" ")
        # Create the wrapper block.
        $block = $("<#{template.tag}>").append(inlineNodes)
        $block.addClass(classname) for classname in template.classes
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
      replacement = @api.replacement(node)
      $replacement = $("<#{replacement.tag}/>").append(node.childNodes)
      $replacement.addClass(classname) for classname in replacement.classes
      $(node).replaceWith($replacement)
      return $replacement[0]

    # Replaces the node with its children.
    flattenBlock: (node) ->
      if @doNotFlatten.indexOf($(node).tagName()) == -1
        parent = node.parentNode
        parent.insertBefore(node.childNodes[0], node) while node.childNodes[0]
        parent.removeChild(node)

  return Normalizer

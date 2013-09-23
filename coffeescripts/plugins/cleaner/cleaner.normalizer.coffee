# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers", "plugins/cleaner/cleaner.flattener"], ($, Helpers, Flattener) ->
  class Normalizer
    doNotUseAsTemplate: ["ol", "ul", "li", "table", "tbody", "thead", "tfoot", "tr", "th", "td", "caption", "colgroup", "col"]

    # Arguments:
    # * api - SnapEditor API
    # * ignore - an array of selectors to ignore
    constructor: (@api, @ignore) ->
      @flattener = new Flattener(@ignore)

    getCSSSelectors: ->
      @ignore.join(",")

    shouldIgnore: (node) ->
      Helpers.isElement(node) and $(node).filter(@getCSSSelectors()).length > 0

    # Normalizes all the nodes between and including startNode and endNode.
    # Assumes startNode and endNode have the same parent.
    # All elements will be checked against the whitelist and replaced if needed.
    # All contiguous inline top nodes will be wrapped in a block.
    # All top blocks will be flattened.
    # All ignored elements will not be replaced and the insides left alone.
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
    # it flattens them. The exception are elements to ignore. These are
    # not replaced and their insides are not normalized.
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

          # If the node is to be ignored, don't replace it or normalize the inside.
          isIgnore = @shouldIgnore(node)

          # Don't replace the node if it is to be ignored.
          unless isIgnore
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
            # Don't normalize the inside if node is to be ignored.
            if isIgnore
              # Inline nodes that are ignored should still be treated as
              # inline.
              inlineNodes.push(node) unless isBlock
            else
              # Normalize the children first.
              innerBlockFound = @normalizeNodes(node.firstChild, node.lastChild)

              if innerBlockFound or !replacement or (isBlock and !node.firstChild and node.tagName != "IMG")
                # If inner blocks were found, there is no inline replacement,
                # or the block is empty, flatten the outer element.

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
          $block = $(@api.getDefaultBlock())
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
    # Otherwise, return null (null should only be returned if the node is on
    # the blacklist or is inline with no replacement).
    checkWhitelist: (node) ->
      return node unless Helpers.isElement(node)
      return node if @api.isAllowed(node)
      return null if @blacklisted(node)
      replacement = @api.getReplacement(node)
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

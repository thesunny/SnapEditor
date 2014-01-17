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
    #
    # This describes the entire process that will happen:
    # * All elements will be checked against the whitelist and replaced if needed.
    # * All contiguous inline top nodes will be wrapped in a block.
    # * All top blocks will be flattened.
    # * All ignored elements will not be replaced and the insides left alone.
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
      # @loopThroughNodes startNode, endNode, (node) ->
      #   console.log node


    # It is expected that the startNode and endNode have the same parent.
    #
    # If all the nodes are inline nodes, this does nothing.
    #
    # If there are any blocks, it makes sure that all inline nodes are in a block.
    # We want either all the nodes to be inline or all the nodes to be blocks.
    # This is important because when we move these nodes up a level, we are
    # expecting them this way. If they aren't we may end up with mixed blocks
    # and inlines at the top level which is not what we want.
    #
    # It then goes and normalizes those blocks. If there are any nested blocks,
    # it flattens them. The exception are elements to ignore. These are
    # not replaced and their insides are not normalized.
    # Returns true if there are any blocks. False otherwise.
    #
    # One of the interesting things about normalizeNodes is that it tries to
    # keep the children as inlines for as long as possible. As soon as the
    # children have a block in it, then everything at that level must be in a
    # block. One alternative that wouldn't work is to immediately turn every
    # level of call into a block, but that would wreck the fact that nested
    # inlines should continue to be inline, even if they are at different
    # levels in the DOM.
    normalizeNodes: (startNode, endNode) ->
      blockFound = false
      if startNode and endNode
        inlineNodes = []
        @loopThroughNodes startNode, endNode, (node) =>

          # If the node is to be ignored, don't replace it or normalize the inside.
          isIgnore = @shouldIgnore(node)

          # REPLACEMENT
          #
          # This section deals with replacing the current node.

          # Don't replace the node if it is to be ignored.
          unless isIgnore
            # Handle whitelisting of the node first.
            # 
            # TODO: In this call, we are actually doing the replacements in the
            # DOM. Change method name to reflect this.
            #
            # After this call is made, the current node will be whitelisted
            # already.
            #
            # TODO: @checkWhiteList actually returns something that is more
            # like a status. The status can be a node which can either be (a)
            # the same node as the given node (b) a whitelisted and replaced
            # node that was dropped into the DOM or (c) null, which means the
            # current node should be deleted and replaced with its children.
            replacement = @checkWhitelist(node)
            # If the node has been replaced, use the replacement.
            node = replacement if replacement

          # PREVIOUS INLINE NODES
          #
          # This section deals with handling previously found inline nodes
          # if the current node is a block.
          #
          # Note: @blockify modifies the DOM in place so after the call, the
          # DOM has been fixed already.
          isBlock = Helpers.isBlock(node)
          if isBlock
            # Blockify any previous inline nodes.
            blockFound = true
            @blockify(inlineNodes, node)
            inlineNodes = []

          # CHILDREN AND INLINE
          #
          # This section deals with:
          #
          # * handling what happens to the children of the current node
          # * pushing the current inline node onto the list of inline nodes
          if Helpers.isElement(node)
            # Don't normalize the inside if node is to be ignored.
            #
            # The use cases for this are atomic elements, widgets and whatever
            # else the user may want to ignore.
            if isIgnore
              # Inline nodes that are ignored should still be treated as
              # inline.
              inlineNodes.push(node) unless isBlock
            else
              # Special Handling of PRE right now
              #
              # If the node is a "pre" block, then we should kill all the
              # inner HTML since that is invalid in markup.
              if node.tagName.toLowerCase() == "pre"
                @cleanNodeToText(node)
              else
                # Normalize the children first and if the children have any inner
                # blocks inside, all of the children will be in blocks.
                #
                # TODO: Consider renaming innerBlockFound to something like
                # innerBlockMode.
                innerBlockFound = @normalizeNodes(node.firstChild, node.lastChild)

                # CHILDREN REPLACE CURRENT
                #
                # This section asks the question, do we want to replace the current
                # node with its children.
                #
                # Checks to see if this node needs to be flattened and if it does
                # replace the current node with the children node in the DOM.
                #
                # TODO:
                # NOTE: In this check, images are identified as blocks which is
                # not true in CSS. This is a decision we made earlier but may
                # change in the future, especially if we turn to a markdown or
                # other mark up style editor.
                #
                # !replacement means that the current node is marked to be deleted.
                # This section deletes the current node but makes sure the
                # children are not wiped out too. It moves the children up to
                # replace the current node.
                #
                # if it is a block and it's empty, we should replace the current
                # node with its children (i.e. delete the block). The only time
                # we don't want to do this is if the node is an image. This is
                # because in our current code we had decided that an image will
                # be treated like a block.
                #
                # TODO: Consider not handling an image as a block because we may
                # turn this into a mark up editor and they don't treat images
                # as block.

                if innerBlockFound or !replacement or (isBlock and !node.firstChild and node.tagName != "IMG")
                  # The first and last children may have changed after the call to
                  # @normalizeNodes. Hence, we grab them here instead of earlier in
                  # the loop.
                  #
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

          # # If we are at the endNode break out of the loop.
          # break if stop
          # node = nextSibling

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
        #
        # Normally, we would copy the parent block type, for example, if the
        # parent was a div, we'd put the inlines within another div. If it was
        # a p, we'd make more p elements; however, @doNotUseAsTemplate
        # tells us that certain parent elements don't make sense this way so
        # in that case, we use @api.getDefaultBlock to find out what we should
        # use.
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
    #
    # * If the node is a textnode, returns the textnode.
    # * If the node is an element and is on the whitelist, return the node.
    # * If the node is a not on the whitelist and a replacement can be found,
    #   replace the node with the replacement and return it.
    # * Otherwise, return null (null should only be returned if the node is on
    #   the blacklist or is inline with no replacement).
    #
    # TODO: Consider renaming this whitelistNode or something as this method
    # doesn't just check the whitelist, it will also make the replacement.
    checkWhitelist: (node) ->
      return node if !Helpers.isElement(node)
      return node if @api.isAllowed(node)
      return null if @blacklisted(node)
      replacement = @api.getReplacement(node)
      $(node).replaceElementWithKeepChildren(replacement) if replacement
      return replacement

    # Checks to see if the node on the list is something we just want to delete.
    # For example, all the apple added garbage should be removed.
    blacklisted: (node) ->
      return false unless Helpers.isElement(node)
      blacklisted = false
      $el = $(node)
      switch $el.tagName()
        when "br" then blacklisted = $el.hasClass("Apple-interchange-newline")
        when "span" then blacklisted = $el.hasClass("Apple-style-span") or $el.hasClass("Apple-tab-span")
      return blacklisted

    # This checks to see if the given node is an element used to denote
    # part of a range. Currently, this method is used to cleanNodeToText.
    #
    # TODO:
    # For other cleaning we are using the whitelist which contains the Range
    # as well. This is actually somewhat unfortunate because similar code is in
    # two different places.
    #
    # We should actually remove the range from the whitelist as the whitelist
    # should actually include the elements that are permanently allowed in the
    # HTML.
    isRangeElement: (node) ->
      tag = node.tagName.toLowerCase()
      id = node.id
      return (tag == 'span' and (id == "RANGE_START" or id == "RANGE_END")) or
        (tag == 'img' and id == "RANGE_IMAGE")

    # Cleans the node so that the only thing left is the stuff in the
    # whitelist.
    cleanNodeToText: (node) ->
      @cleanNodesToText node.firstChild, node.lastChild

    # It is expected that startNode and endNode both have the same parent
    # because it is usually called from cleanNodeToText
    cleanNodesToText: (startNode, endNode) ->
      @loopThroughNodes startNode, endNode, (node) =>
        if Helpers.isElement(node) && !@isRangeElement(node)
          Helpers.replaceWithChildren(node)

    # Loops through all the nodes starting with startNode and ending with
    # endNode. Assumes that the startNode and endNode have the same parent.
    loopThroughNodes: (startNode, endNode, fn) ->
      node = startNode
      # Loop through all the nodes between and including startNode and
      # endNode.
      loop
        # Grab all relevant info first because the node may be removed.
        stop = node == endNode
        nextNode = node.nextSibling
        fn node
        node = nextNode
        break if stop


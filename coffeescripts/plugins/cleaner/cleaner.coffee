# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["snapeditor.pre", "jquery.custom", "core/helpers", "plugins/cleaner/cleaner.normalizer"], (SnapEditor, $, Helpers, Normalizer) ->
  # NOTE: TODO:
  # At this time, the cleaner doesn't check to make sure that the DOM is
  # correct. For example, it won't ensure that all the children of a <ul> are
  # <li> elements.
  cleaner =
    # ONLY PUBLIC ENTRY POINT
    # Given a range, it saves the range, performs the clean up, then
    # repositions the range.
    # Given a startNode and endNode, it cleans up between and including
    # startNode and endNode.
    clean: ->
      self = this
      switch arguments.length
        # This is cleaning the range as defined by the cursor
        # TODO: Consider renaming cleanRange.
        when 0 then @keepRange(@cleanup)
        # This is cleaning based on nodes
        when 2 then @cleanup.apply(this, arguments)
        else throw "Wrong number of arguments to Cleaner.clean(). Expecting nothing () or (startNode, endNode)."
      @api.trigger("snapeditor.cleaner_finished")

    # Cleans up and normalizes all the nodes between and including startNode
    # and endNode.
    cleanup: (startNode, endNode) ->
      if startNode and endNode
        el = @api.el
        # Helpers.getTopNode bubbles up to the topmost node.
        # @expandTopNode selects furthest non-block node before/after given node
        # unless we are currently in a block.
        startTopNode = @expandTopNode(Helpers.getTopNode(startNode, el), true)
        endTopNode = @expandTopNode(Helpers.getTopNode(endNode, el), false)
        new Normalizer(@api, @api.config.cleaner.ignore).normalize(startTopNode, endTopNode)

    # If the node is an inline node, it either looks backwards or forwards
    # until it hits a block or the end. It then returns the node before the
    # block.
    #
    # This is necessary because the DOM hasn't been cleaned yet and therefore
    # non-block nodes can be present at the top. This ensures that the clean
    # happens always starting and ending with a block.
    # 
    # If the node is a block node, it returns it.
    expandTopNode: (node, backwards) ->
      return node if Helpers.isBlock(node)
      direction = if backwards then "previousSibling" else "nextSibling"
      topNode = node
      sibling = topNode[direction]
      while sibling and !Helpers.isBlock(sibling)
        topNode = sibling
        sibling = topNode[direction]
      return topNode

    # In IE8 only, while the cleaner is running, the range gets destroyed and
    # it cannot be regained programatically or by the user. To keep this from
    # happening, we unselect the current range before cleaning to ensure that
    # it doesn't get destroyed. API.keepRange() will reset the range anyways so
    # it's okay. This hack has no effect on the other browsers, hence it is
    # left in for consistency.
    keepRange: (fn) ->
      self = this
      # The startNode and endNode are the inserted nodes from keepRange.
      # TODO: Consider renaming startNode and endNode to insertedStartNode
      # and insertedEndNode.
      @api.keepRange((startNode, endNode) ->
        self.api.unselect()
        fn.apply(self, [startNode, endNode])
      )

  SnapEditor.behaviours.cleaner =
    # We set this before activation because other plugins may need to call
    # the cleaner. We assume only one editor is active at a time so this
    # pointer will be set properly for the duration of the editor's use.
    onBeforeActivate: (e) ->
      cleaner.api = e.api
    onActivate: (e) ->
      # keepRange() is used because onActivate, the cursor position must be
      # preserved after cleaning. 
      #
      # This is actually a special case. Normally you don't need to explicitly
      # call keepRange because the range will be preserved just with the call
      # to clean. It's an issue probably to do with activation.
      #
      # Note that this assumes that we are working with one editor at a time
      # which is true. We set cleaner.api in onBeforeActivate so we have
      # access to cleaner.api in this method call.
      #
      cleaner.keepRange(-> @clean(@api.el.firstChild, @api.el.lastChild))
    onClean: (e, args...) ->
      cleaner.clean.apply(cleaner, args)

  # cleaner is returned for testing purposes.
  return cleaner

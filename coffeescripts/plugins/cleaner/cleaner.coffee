# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers", "plugins/cleaner/cleaner.normalizer"], ($, Helpers, Normalizer) ->
  cleaner =
    # Given a range, it saves the range, performs the clean up, then
    # repositions the range.
    # Given a startNode and endNode, it cleans up between and including
    # startNode and endNode.
    clean: ->
      self = this
      switch arguments.length
        when 0 then @keepRange(@cleanup)
        when 2 then @cleanup.apply(this, arguments)
        else throw "Wrong number of arguments to Cleaner.clean(). Expecting nothing () or (startNode, endNode)."
      @api.trigger("snapeditor.cleaner_finished")

    # Cleans up and normalizes all the nodes between and including startNode
    # and endNode.
    cleanup: (startNode, endNode) ->
      if startNode and endNode
        el = @api.el
        startTopNode = @expandTopNode(Helpers.getTopNode(startNode, el), true)
        endTopNode = @expandTopNode(Helpers.getTopNode(endNode, el), false)
        new Normalizer(@api, @api.config.cleaner.ignore).normalize(startTopNode, endTopNode)

    # If the node is an inline node, it either looks backwards or forwards
    # until it hits a block or the end. It then returns the node before the
    # block.
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
      @api.keepRange((startNode, endNode) ->
        self.api.unselect()
        fn.apply(self, [startNode, endNode])
      )

  SnapEditor.behaviours.cleaner =
    onBeforeActivate: (e) ->
      cleaner.api = e.api
    onActivate: (e) ->
      # keepRange() is used because onActivate, the cursor position must be
      # preserved after cleaning.
      cleaner.keepRange(-> @clean(@api.el.firstChild, @api.el.lastChild))
    onClean: (e, args...) ->
      cleaner.clean.apply(cleaner, args)

  # cleaner is returned for testing purposes.
  return cleaner

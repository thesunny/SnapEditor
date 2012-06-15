define ["jquery.custom", "core/helpers", "plugins/cleaner/cleaner.normalizer"], ($, Helpers, Normalizer) ->
  class Cleaner
    register: (@api) ->
      @$el = $(@api.el)
      @normalizer = new Normalizer(@api)
      @api.on("activate.editor", => @keepRange(=> @clean(@api.el.firstChild, @api.el.lastChild)))
      @api.on("clean", (e, args...) => @clean.apply(this, args))
      @clean(@api.el.firstChild, @api.el.lastChild)

    # Given a range, it saves the range, performs the clean up, then
    # repositions the range.
    # Given a startNode and endNode, it cleans up between and including
    # startNode and endNode.
    clean: ->
      switch arguments.length
        when 0 then @keepRange(@cleanup)
        when 2 then @cleanup.apply(this, arguments)
        else throw "Wrong number of arguments to Cleaner.clean(). Expecting nothing () or (startNode, endNode)."
      @api.trigger("finished.cleaner")

    # Cleans up and normalizes all the nodes between and including startNode
    # and endNode.
    cleanup: (startNode, endNode) =>
      if startNode and endNode
        startTopNode = @expandTopNode(@findTopNode(startNode), true)
        endTopNode = @expandTopNode(@findTopNode(endNode), false)
        @normalizer.normalize(startTopNode, endTopNode)

    # Runs up the parent chain and returns the node at the top.
    findTopNode: (node) ->
      topNode = node
      parent = topNode.parentNode
      while parent != @api.el
        topNode = parent
        parent = topNode.parentNode
      return topNode

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
    keepRange: (fn) =>
      @api.keepRange(=>
        @api.unselect()
        fn()
      )

  return Cleaner

define ["jquery.custom", "core/helpers", "plugins/cleaner/cleaner.normalizer"], ($, Helpers, Normalizer) ->
  window.SnapEditor.internalPlugins.cleaner =
    events:
      pluginsReady: (e) ->
        el = e.api.el
        e.api.config.plugins.cleaner.clean(e.api, el.firstChild, el.lastChild)
      activate: (e) ->
        api = e.api
        el = api.el
        plugin = api.config.plugins.cleaner
        plugin.keepRange(api, -> plugin.clean(api, el.firstChild, el.lastChild))
      clean: (e, args...) ->
        args.unshift(e.api)
        plugin = e.api.config.plugins.cleaner
        plugin.clean.apply(plugin, args)

    # The first arguments is the API.
    # Given a range, it saves the range, performs the clean up, then
    # repositions the range.
    # Given a startNode and endNode, it cleans up between and including
    # startNode and endNode.
    clean: ->
      self = this
      switch arguments.length
        when 1 then @keepRange(arguments[0], -> self.cleanup.apply(self, arguments))
        when 3 then @cleanup.apply(this, arguments)
        else throw "Wrong number of arguments to Cleaner.clean(). Expecting (api) or (api, startNode, endNode)."
      arguments[0].trigger("snapeditor.cleaner_finished")

    # Cleans up and normalizes all the nodes between and including startNode
    # and endNode.
    cleanup: (api, startNode, endNode) ->
      if startNode and endNode
        startTopNode = @expandTopNode(@findTopNode(api.el, startNode), true)
        endTopNode = @expandTopNode(@findTopNode(api.el, endNode), false)
        new Normalizer(api, api.config.cleaner.ignore).normalize(startTopNode, endTopNode)

    # Runs up the parent chain and returns the node at the top.
    findTopNode: (stopNode, node) ->
      topNode = node
      parent = topNode.parentNode
      while parent != stopNode
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
    keepRange: (api, fn) ->
      api.keepRange((startNode, endNode) ->
        api.unselect()
        fn(api, startNode, endNode)
      )

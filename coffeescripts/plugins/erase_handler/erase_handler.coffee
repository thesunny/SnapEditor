# TODO: The atomic plugin requires the ability to override the delete in
# certain scenarios. However, because there is no events infrastructure in
# place, we have to add the atomic plugin deletion code here, which is not the
# correct place. However, this is the only way it will work. This is a hack
# for now. When the events infrastructure is in place, we should move the
# atomic deletion code back to the atomic plugin. The original file before the
# atomic deletion code was added can be found at
# erase_handler.before_atomic.coffee.
#
# Handles the annoying spans that Safari adds when it merges lines together
# after deleting content through the delete or backspace button.
#
# NOTE: This seems to be a Safari only issue. Chrome does not seem to exhibit
# this behaviour. However, it does no harm including it for Chrome.
#
# Example:
# <h1>This is a header</h1>
# <p>Some text</p>
#
# If the cursor is at the end of the h1 or beginning of the p, when we merge the
# two lines together, Safari will attempt to keep "Some text" styled normally
# (non-h1).
# <h1>This is a header<span class="Apple-CRAP">Some text</span></h1>
#
# This is unexpected behaviour. We should expect "Some text" to be styled as h1.
# <h1>This is a header Some text</h1>
define ["jquery.custom", "core/helpers", "core/browser"], ($, Helpers, Browser) ->
  class EraseHandler
    register: (@api) ->
      @api.on("snapeditor.activate", @activate)
      @api.on("snapeditor.deactivate", @deactivate)

    activate: =>
      $(@api.el).on("keydown", @onkeydown)
      $(@api.el).on("keyup", @onkeyup)

    deactivate: =>
      $(@api.el).off("keydown", @onkeydown)
      $(@api.el).off("keyup", @onkeyup)

    onkeydown: (e) =>
      key = Helpers.keyOf(e)
      if key == 'delete' or key == 'backspace'
        # Handle the deletion of the atomic element. If no atomic element was
        # deleted, continue with the normal flow of the erase handler.
        unless @deleteAtomicElement(e, key)
          if Browser.isWebkit
            if @api.isCollapsed()
              @handleCursor(e)
            else
              e.preventDefault()
              @api.delete()

    onkeyup: (e) =>
      # Cleaning is done on keyup in case the browser's default was allowed to
      # occur. In this case, the cleaning will happen afterwards.
      key = Helpers.keyOf(e)
      @api.clean() if key == 'delete' or key == 'backspace'

    handleCursor: (e) ->
      range = @api.getRange()
      parentEl = range.getParentElement((el) -> Helpers.isBlock(el))

      # Attempt to find the two nodes to merge.
      key = Helpers.keyOf(e)
      if key == 'delete' and range.isEndOfElement(parentEl)
        aNode = parentEl
        bNode = $(parentEl).next()[0]
      else if key == 'backspace' and range.isStartOfElement(parentEl)
        aNode = $(parentEl).prev()[0]
        bNode = parentEl

      # Merge nodes if aNode given.
      if aNode and bNode
        # Call preventDefault first so that if @mergeNodes fails, nothing
        # happens. This will alert us to bugs sooner (crash early).
        e.preventDefault()
        @api.keepRange(-> $(aNode).merge(bNode))

    deleteAtomicElement: (e, key) ->
      deleted = false
      # Nothing to do if a selection is found.
      return deleted unless @api.isCollapsed()
      # Delete the atomic element if needed. Note that startEl == endEl
      # because the range is collapsed.
      api = @api
      @api.keepRange((startEl, endEl) ->
        if key == "delete"
          el = endEl
          which = "next"
        else
          el = startEl
          which = "previous"
        # Grab the previous/next sibling.
        # If we find a sibling that is a textnode with no content, skip it.
        sibling = Helpers.getSibling(which, el, api.el, (node) ->
          return node unless Helpers.isTextnode(node)
          !node.nodeValue.match(Helpers.emptyRegExp)
        )
        # If the sibling exists and is an atomic element, delete it.
        if sibling and Helpers.isElement(sibling) and $(sibling).hasClass(api.config.atomic.classname)
            e.preventDefault()
            $(sibling).remove()
            deleted = true
      )
      deleted

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
define ["cs!jquery.custom", "cs!core/helpers", "cs!core/browser"], ($, Helpers, Browser) ->
  class EraseHandler
    register: (@api) ->
      if Browser.isWebkit
        @api.on("activate.editor", @activate)
        @api.on("deactivate.editor", @deactivate)

    activate: =>
      $(@api.el).on("keydown", @onkeydown)

    deactivate: =>
      $(@api.el).off("keydown")

    onkeydown: (e) =>
      key = Helpers.keyOf(e)
      if key == 'delete' or key == 'backspace'
        if @api.isCollapsed()
          @handleCursor(e)
        else
          @handleSelection(e)

    handleCursor: (e) ->
      range = @api.range()
      parentNode = range.getParentElement(@isBlockElement)

      # Attempt to find the two nodes to merge.
      key = Helpers.keyOf(e)
      if key == 'delete' and range.isEndOfNode(parentNode)
        aNode = parentNode
        bNode = $(parentNode).next()[0]
      else if key == 'backspace' and range.isStartOfNode(parentNode)
        aNode = $(parentNode).prev()[0]
        bNode = parentNode

      # Merge nodes if aNode given.
      if aNode
        # Call preventDefault first so that if @mergeNodes fails, nothing
        # happens. This will alert us to bugs sooner (crash early).
        e.preventDefault()
        @mergeNodes(aNode, bNode)

    handleSelection: (e) ->
      startRange = @api.range().collapse(true)
      endRange = @api.range().collapse(false)
      startParentNode = startRange.getParentElement(@isBlockElement)
      endParentNode = endRange.getParentElement(@isBlockElement)
      # If the start and end parentNodes don't match, then we need to manually
      # merge the nodes together.
      if startParentNode != endParentNode
        e.preventDefault()
        @api.remove()
        @mergeNodes(startParentNode, endParentNode)

    isBlockElement: (el) ->
      $el = $(el)
      $el.css('display') == 'block' or $el.tagName() == 'li'

    mergeNodes: (a, b) ->
      # Remember where the cursor is.
      $span = $('<span id="EDITOR_CURSOR_POS"></span>')
      $(a).append($span)
      # Merge b into a.
      while(b.childNodes[0])
        a.appendChild(b.childNodes[0])
      $(b).remove()
      a.normalize()
      # Reselect the cursor.
      @api.range($span[0]).collapse(false).select()
      $span.remove()

  return EraseHandler

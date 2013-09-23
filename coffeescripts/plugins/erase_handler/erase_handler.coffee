# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
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
  eraseHandler =
    activate: (@api) ->
      self = this
      @onkeydownHandler = (e) -> self.onkeydown(e)
      @onkeyupHandler = (e) -> self.onkeyup(e)
      @api.on("snapeditor.keydown", @onkeydownHandler)
      @api.on("snapeditor.keyup", @onkeyupHandler)

    deactivate: ->
      @api.off("snapeditor.keydown", @onkeydownHandler)
      @api.off("snapeditor.keyup", @onkeyupHandler)

    onkeydown: (e) ->
      key = Helpers.keyOf(e)
      if key == 'delete' or key == 'backspace'
        # Handle the deletion of an entire element. If no entire element was
        # deleted, continue with the normal flow of the erase handler.
        unless @delete(e, key)
          if Browser.isWebkit
            # Webkit is the only browser we have to override the default
            # deleting because it does some funky stuff.
            if @api.isCollapsed()
              @merge(e)
            else
              e.preventDefault()
              @api.delete()

    onkeyup: (e) ->
      # Cleaning is done on keyup in case the browser's default was allowed to
      # occur. In this case, the cleaning will happen afterwards.
      key = Helpers.keyOf(e)
      @api.clean() if key == 'delete' or key == 'backspace'

    merge: (e) ->
      range = @api.getRange()
      parentEl = range.getParentElement((el) -> Helpers.isBlock(el))

      # Attempt to find the two nodes to merge.
      key = Helpers.keyOf(e)
      if key == 'delete' and range.isEndOfElement(parentEl)
        aEl = parentEl
        bEl = $(parentEl).next()[0]
      else if key == 'backspace' and range.isStartOfElement(parentEl)
        aEl = $(parentEl).prev()[0]
        bEl = parentEl

      # Merge nodes if both found.
      if aEl and bEl
        # Call preventDefault first so that if @merge fails, nothing
        # happens. This will alert us to bugs sooner (crash early).
        e.preventDefault()
        if $(aEl).tagName() == "hr"
          # If we're backspacing an <hr>, simply delete the <hr> instead of
          # merging.
          $(aEl).remove()
        else
          @api.keepRange(-> $(aEl).merge(bEl))

    getCSSSelectors: ->
      ["hr"].concat(@api.config.eraseHandler.delete).join(",")

    shouldDelete: (node) ->
      node and Helpers.isElement(node) and $(node).filter(@getCSSSelectors()).length > 0

    delete: (e, key) ->
      deleted = false
      # Nothing to do if a selection is found.
      return deleted unless @api.isCollapsed()
      # Delete the element if needed. Note that startEl == endEl because the
      # range is collapsed.
      self = this
      @api.keepRange((startEl, endEl) ->
        if key == "delete"
          el = endEl
          which = "next"
        else
          el = startEl
          which = "previous"
        # Grab the previous/next sibling.
        # If we find a sibling that is a textnode with no content, skip it.
        sibling = Helpers.getSibling(which, el, self.api.el, (node) ->
          return node unless Helpers.isTextnode(node)
          !node.nodeValue.match(Helpers.emptyRegExp)
        )
        # If the sibling exists and should be deleted, delete it.
        if self.shouldDelete(sibling)
            e.preventDefault()
            $(sibling).remove()
            deleted = true
      )
      deleted

  SnapEditor.behaviours.eraseHandler =
    onActivate: (e) -> eraseHandler.activate(e.api)
    onDeactivate: (e) -> eraseHandler.deactivate()

  # eraseHandler is returned for testing purposes.
  return eraseHandler

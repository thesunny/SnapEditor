# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  class Flattener
    # TODO:
    # NOTE:
    # Right now we support atomic elements and widgets. These are blocks.
    # The problem is that in some of our code, we prevent blocks from being
    # in other types of elements like TD and LI. However, so that we don't
    # destroy atomic elements and widgets during a clean, we've written in
    # an exception. However, by doing this, we have a nasty mixed state issue
    # where we don't allow blocks except when we do (i.e. atomic elements and
    # widgets). We should fix this so either we allow both or disallow both.
    # In the case where we disallow, we can push those elements out of the
    # table or li when they are atomic or widgets and fix them when they aren't.

    # Arguments:
    # * ignore - an array of selectors to ignore
    constructor: (@ignore) ->

    # List of element types that we do not need to flatten.
    #
    # TODO:
    # Probably we can replace li, td, and th because they are already handled
    # in @flatten in the switch statement.
    doNotReplace: ["ol", "ul", "li", "table", "tbody", "thead", "tfoot", "tr", "th", "td", "caption"]

    # PUBLIC:
    # Main entry point.
    #
    # One assumption here is that the children of the node have already been
    # flattened. This is true because of where it is called in the normalizer.
    #
    # TODO:
    # NOTE:
    # When we hit something in the @doNotReplace list, we have actually assumed
    # that the DOM is not in an invalid state like having a <p> tag directly
    # under a <ul> or <ol> tag. Our cleaner wouldn't cause this to happen in
    # the process of cleaning, but it also won't fix, at this time, if the
    # browser has allowed some invalid nesting. We may wish to consider, if we
    # ever see it crop up, to have the cleaner fix this. For example, by forcing
    # all the children of a <ul> or <ol> tag to be <li>.
    #
    # NOTE:
    # All the children of the node are blocks because this method never gets
    # called if all the children are inlines. Remember, that the children will
    # be all blocks or all inlines.
    flatten: (node) ->
      switch $(node).tagName()
        when "li" then @flattenListItem(node)
        when "td", "th" then @flattenTableCell(node)
        else Helpers.replaceWithChildren(node) if $.inArray($(node).tagName(), @doNotReplace) == -1

    # Flattens the given block by bubbling up all inline nodes which will be
    # separated by the template.
    # If a list is given, each list item's content will be bubbled up and
    # separated by the template.
    # If a table is given, each cell's content will be bubbled up and separated
    # by the template.
    # If the block is not special, the block will be replaced by its children.
    #
    # TODO:
    # Template right now is only ever <br> so we may not want to pass that in.
    flattenBlock: (block, template) ->
      $block = $(block)
      # If the block is not special, just replace the block with it's children.
      # If the block is special, we need to replace the block with the
      # appropriate descendants.
      switch $block.tagName()
        when "ol", "ul" then $els = $block.children()
        when "table" then $els = $block.find("th, td")
        else return Helpers.replaceWithChildren(block)
      # Place all the contents of the elements before the parent, separated by
      # the template.
      for i in [0..$els.length-1]
        el = $els[i]
        $block.before(el.childNodes[0]) while el.childNodes[0]
        # Don't insert the template if it is the last element.
        $block.before($(template).clone()) unless i == $els.length - 1
      # Remove the block because we don't need it anymore.
      $block.remove()

    # Flattens all blocks into new list items.
    # This assumes that all the children in the list item are blocks.
    # If a list is found, it is not flattened into a list item. Instead it is
    # taken out of the list item.
    # If a table is found, all the cells are flattened into new list items.
    #
    # NOTE: Use #insertBefore() to preserver order.
    flattenListItem: (node) ->
      $template = $(Helpers.getDocument(node).createElement("li"))
      # The way this works is that it looks at the current node and then
      # builds the new nodes by moving them out of the childNodes and placing
      # them before the current node. This way, node.childNodes[0] is always
      # the next child that hasn't been processed yet.
      while node.childNodes[0]
        child = node.childNodes[0]
        switch $(child).tagName()
          when "ul", "ol"
            # Rip the list out of the list item.
            $(child).insertBefore(node)
          when "table"
            # If the child is a table (i.e. it is atomic or a widget) then we
            # don't remove it from the DOM even though our editor, at present,
            # doesn't allow tables inside list items. The decision for this
            # at the time was for legacy code that may have allowed it.
            #
            # TODO: We may we to change this behavior and just delete tables
            # inside list items even if they somehow got there before.
            # If we cut and pasted a table, it would actually turn it into a
            # list in the normal case. If we cut and pasted a table that
            # should be ignored, then under our new scenario, it would just
            # get deleted which would be confusing. An alternative might be
            # to move the atomic table outside (just before or just after) the
            # top level block.
            if @shouldIgnore(child)
              # If the table is to be ignored, just move the entire table.
              # Don't flatten.
              $li = $template.clone()
              $li.append(child)
              $li.insertBefore(node)
            else
              # Create list items per cell.
              $cells = $(child).find("th, td")
              for cell in $cells
                $li = $template.clone()
                $li.html(cell.innerHTML)
                $li.insertBefore(node)
              $(child).remove()
          else
            # Create a list item out of the block.
            $li = $template.clone()
            if @shouldIgnore(child)
              # If the child is to be ignored, just move the entire child.
              $li.append(child)
            else
              # Just move the insides of the child.
              $li.html(child.innerHTML)
              $(child).remove()
            $li.insertBefore(node)
      $(node).remove()

    # Removes all blocks from the cell and places <br>s between them.
    # This assusmes that all the children in the cell are blocks.
    # Ignored elements are left alone.
    #
    # NOTE:
    # The reason why we know that all the children are blocks is because in
    # the normalizer, this method never gets called if all the children are
    # inlines. Remember that all children in normalizer will be inlines or
    # all blocks.
    #
    # TODO:
    # NOTE: This is a little bit in nasty territory where we support atomic
    # elements and widgets inside a table cell which are blocks but we don't
    # allow any other blocks to exist inside the table cell. This kind of
    # gives us the worst of both worlds. When switching to a mark up editor,
    # we can probably remove the @shouldIgnore stuff unless we find markup
    # editors that also support widgety things.
    #
    # NOTE:
    # Unlike list items, the blocks generally tend to be changed in place
    # and then the <br> elements are added where required.
    flattenTableCell: (node) ->
      $template = $(Helpers.getDocument(node).createElement("br"))
      child = node.childNodes[0]
      while child
        nextSibling = child.nextSibling
        if @shouldIgnore(child)
          # If the child is to be ignored, remove the previous <br> and skip
          # flattening it.
          $(child.previousSibling).remove() if child.previousSibling
        else
          @flattenBlock(child, $template)
          # Insert a <br> if there is a next sibling.
          $template.clone().insertBefore(nextSibling) if nextSibling
        child = nextSibling

    getCSSSelectors: ->
      @ignore.join(",")

    shouldIgnore: (node) ->
      Helpers.isElement(node) and $(node).filter(@getCSSSelectors()).length > 0

  return Flattener

# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  class Flattener
    # Arguments:
    # * ignore - an array of selectors to ignore
    constructor: (@ignore) ->

    doNotReplace: ["ol", "ul", "li", "table", "tbody", "thead", "tfoot", "tr", "th", "td", "caption"]

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
      while node.childNodes[0]
        child = node.childNodes[0]
        switch $(child).tagName()
          when "ul", "ol"
            # Rip the list out of the list item.
            $(child).insertBefore(node)
          when "table"
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

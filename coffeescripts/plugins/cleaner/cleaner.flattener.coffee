define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  class Flattener
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
        when "ol", "ul" then selector = "li"
        when "table" then selector = "th, td"
        else return Helpers.replaceWithChildren(block)
      # Find all the elements and place their contents before the parent,
      # separated by the template.
      $els = $block.find(selector)
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
            # Create list items per cell.
            $cells = $(child).find("th, td")
            for cell in $cells
              $li = $template.clone()
              $li.html(cell.innerHTML)
              $li.insertBefore(node)
            $(child).remove()
          else
            # Create list items per block.
            $li = $template.clone()
            $li.html(child.innerHTML)
            $li.insertBefore(node)
            $(child).remove()
      $(node).remove()

    # Removes all blocks from the cell and places <br>s between them.
    # This assusmes that all the children in the cell are blocks.
    flattenTableCell: (node) ->
      $template = $(Helpers.getDocument(node).createElement("br"))
      child = node.childNodes[0]
      while child
        nextSibling = child.nextSibling
        @flattenBlock(child, $template)
        # Insert a <br> if there is a next sibling.
        $template.clone().insertBefore(nextSibling) if nextSibling
        child = nextSibling

  return Flattener

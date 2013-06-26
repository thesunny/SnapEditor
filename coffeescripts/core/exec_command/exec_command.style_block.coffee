define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  paragraphTags = ["p", "h1", "h2", "h3", "h4", "h5", "h6"]
  listTags = ["ul, ol, li"]
  tableTags = ["table", "tr", "th", "td"]
  blockTags = paragraphTags.concat(listTags).concat(tableTags)

  return {
    # Style is in the form of a CSS selector on a single element.
    # e.g.
    #   tag - h1
    #   single class - h1.special
    #   multiple classes - h1.special.title
    style: (style, editor) ->
      styles = style.split(".")
      tag = styles.shift()
      # TODO: What happens if everything is selected.
      [startParentEl, endParentEl] = @editor.getParentElements(blockTags.join(","))
      els = @getElementsBetween(startParentEl, endParentEl, editor.el)
      @styleElement(el, tag, styles) for el in els

    styleElement: (el, tag, styles) ->

    isCompatible: (tag, el) ->
      compatible = false
      if paragraphTags.indexOf(tag) != -1
        compatible = paragraphTags.indexOf($(el).tagName()) != -1
      else if tableTags.indexOf(tag) != -1
        compatible = tableTags.indexOf($(el).tagName()) != -1
      compatible

    # Returns all the top level elements between and including startEl and
    # endEl. This accounts for starting and ending in a table.
    # If we start in a table, instead of including the table itself, we
    # include all the cells between and including the startEl to the end of
    # the table.
    # If we end in a table, instead of including the table itself, we
    # include all the cells between and including the endEl to the beginning of
    # the table.
    #
    # Arguemnts:
    # startEl - starting element
    # endEl - ending element
    # contextEl - don't go above this element (does not include this element)
    getElementsBetween: (startEl, endEl, contextEl) ->
      if startEl == endEl
        nodes = [startEl]
      else
        startTopEl = Helpers.getTopNode(startEl, contextEl)
        endTopEl = Helpers.getTopNode(endEl, contextEl)
        if $(startTopEl).tagName() == "table" and startTopEl == endTopEl
          # If the start and end are in the same table, we need to grab all the
          # cells in between.
          nodes = @getCells(true, startEl, endEl)
        else
          # Grab all the top level nodes between and including the
          # start/endTopEl.
          nodes = Helpers.nodesFrom(startTopEl, endTopEl)
          if $(startTopEl).tagName() == "table"
            # If we start inside a table, remove the parent table and add on the
            # cells.
            cells = @getCells(true, startEl)
            nodes.shift()
            nodes = cells.concat(nodes)
          if $(endTopEl).tagName() == "table"
            # If we end inside a table, remove the parent table and add on the
            # cells.
            cells = @getCells(false, endEl)
            nodes.pop()
            nodes = nodes.concat(cells)
      # Return only elements.
      els = []
      $.each(nodes, -> els.push(this) if Helpers.isElement(this))
      els

    # Returns all the cells starting from startCell.
    # Arguments:
    # next - true for retrieving the next cells, false for retrieving the
    #   previous cells.
    # startCell - the cell to start at
    # endCell - the cell to end at or null to get all cells
    getCells: (next, startCell, endCell = null) ->
      cells = [startCell]
      cell = startCell
      while((cell = Helpers.getSiblingCell(cell, next)) and cell != endCell)
        cells.push(cell)
      cells.push(endCell) if endCell
      # Reverse the cells if we're finding the previous cells.
      cells.reverse() unless next
      cells
  }

define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  class EmptyListItemHandler
    constructor: (@api) ->

    handle: (item) ->
      $item = $(item)
      $list = $item.parent("ul, ol")
      $prevItems = Array.prototype.reverse.call($item.prevAll())
      $nextItems = $item.nextAll()
      @handlePrevItems($prevItems, $list)
      @handleItem($item, $list)
      @handleNextItems($nextItems, $list)

    handlePrevItems: ($prevItems, $list) ->
      # If there are previous items, clone the current list, place all the
      # previous items into the new list and insert it before the current list.
      unless $prevItems.length == 0
        $prevList = $list.clone().empty()
        $prevList.append($prevItems)
        $prevList.insertBefore($list)

    handleItem: ($item, $list) ->
      if $list.parent("ul, ol").length > 0
        # If the list is nested, rip the item out and place it before the
        # current list.
        $new = $item.html(Helpers.zeroWidthNoBreakSpace)
      else
        # If the list is not nested, remove the item and insert the next block
        # before the current list.
        $item.remove()
        $new = $(@api.next($list[0])).html(Helpers.zeroWidthNoBreakSpace)
      $new.insertBefore($list)
      @api.selectEndOfElement($new[0])

    handleNextItems: ($nextItems, $list) ->
      # If there's nothing left in the list, remove it.
      $list.remove() if $nextItems.length == 0

  return EmptyListItemHandler

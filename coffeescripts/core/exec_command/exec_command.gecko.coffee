# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom"], ($) ->
  return {
    indent: ->
      # In Firefox, when there is only one list item, indent does not create a
      # sublist. Instead, it indents using a margin similarly to a paragraph.
      # This occurs even when a list contains a sublist, but there is only one
      # list item in total.  Therefore, we force it to sublist by adding an
      # empty sibling list item, indenting, then removing the sibling list item.
      [startParent, endParent] = @editor.getParentElements("li")
      # We check to see if we are selecting only one list item. We don't check
      # for the more specific case of there being only one list item to keep
      # the logic simple. The hack of adding and removing a list item is
      # performant enough in all cases.
      if startParent == endParent
        $li = $(@editor.createElement("li")).insertAfter(startParent)
      allowed = @rangeExec("indent")
      $li.remove() if $li
      return allowed
  }

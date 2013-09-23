# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# The Range object attempts to normalize browser differences.
# W3C browsers (including IE9+) use a DOM-base model to handle ranges.
# IE7/8 browsers use a text-based model to handle ranges.
#
# STATIC FUNCTIONS:
# getBlankRange(): creates a new range
# getRangeFromSelection(): gets the range from the current selection
# getRangeFromElement(el): gets the range that encompases the given el
#
# PUBLIC FUNCTIONS:
# These functions are helpers:
# clone(): clones the range
#
# These functions query the state of the range:
# isValid(): is the range inside the element
# isCollapsed(): is the selection a caret
# isImageSelected(): is an image selected
# isStartOfElement(el): is the range at the start of the given element
# isEndOfElement(el): is the range at the end of the given element
# getCoordinates(): gets the coordinates of the range
# getParentElement() : gets parent element of the range
# getParentElements() : gets the start and end parent elements of the range
# getText(): gets the text in the range
#
# These functions manipulate the range.
# collapse(start): collapse range to start or end (returns this)
# select([range]): selects the given range or itself
# unselect(): unselects the range
# selectElementContents(el): selects the contents of the el
# selectEndOfElement(el): selects the inside of the end of el
# keepRange(fn): saves the range, calls the function, reinstates the range
# moveBoundary(boundaries, el): moves a boundary to the start/end of the el
#
# These functions modify the content.
# insert(arg): inserts the given node or html
# surroundContents(el): surrounds the range with the given el
# delete(): delete the contents of the range
#
# Range Intro from QuirksMode:
# http://www.quirksmode.org/dom/range_intro.html
define ["jquery.custom", "core/helpers", "core/range/range.module", "core/range/range.coordinates"], ($, Helpers, Module, Coordinates) ->
  class Range
    # Use this to represent the escape error in getParentElement.
    @EDITOR_ESCAPE_ERROR: new Object(),

    #
    # STATIC FUNCTIONS
    #

    # Get a brand new range.
    @getBlankRange: (win = window) ->
      throw "Range.getBlankRange() needs to be overridden with a browser specific implementation"

    # Gets the currently selected range.
    @getRangeFromSelection: (win = window) ->
      throw "Range.getRangeFromSelection() needs to be overridden with a browser specific implementation"

    # Get a range that surrounds the el.
    @getRangeFromElement: (el) ->
      throw "Range.getRangeFromElement() needs to be overridden with a browser specific implementation"

    # el: Editable element
    # arg:
    #   - window: the range is the current selection
    #   - element: the range surrounds the element
    #   - range: the range is the given range
    #   - nothing: the range is a new range
    constructor: (@el, arg) ->
      throw "new Range() is missing argument el" unless @el
      throw "new Range() el is not an element" unless Helpers.isElement(@el)
      @doc = Helpers.getDocument(@el)
      @win = Helpers.getWindow(@el)
      switch Helpers.typeOf(arg)
        when "window" then @range = Range.getRangeFromSelection(@win)
        when "element" then @range = Range.getRangeFromElement(arg)
        else @range = arg or Range.getBlankRange(@win)

    #
    # HELPER FUNCTIONS
    #

    # Clone the range.
    clone: ->
      new @constructor(@el, @cloneRange())

    # Shortcut to document.createElement().
    # NOTE: This returns a jQuery object.
    createElement: (name) ->
      $(@doc.createElement(name))

    # Shortcut to find the selector in the doc.
    # NOTE: This returns a jQuery object.
    find: (selector) ->
      $(@doc).find(selector)

    #
    # QUERY RANGE STATE FUNCTIONS
    #

    # Is the range valid.
    isValid: ->
      # Invalid if there is no range.
      return false unless @range
      parent = @getParentElement()
      return true unless parent
      return $(parent).parentsUntil(@el, "body").length == 0

    # Is the selection a caret.
    isCollapsed: ->
      throw "#isCollapsed() needs to be overridden with a browser specific implementation"

    # Is an image selected.
    isImageSelected: ->
      throw "#isImageSelected() needs to be overridden with a browser specific implementation"

    # Returns true if the current range is at the start of the given element.
    # We are at start of element if there are no width-generating characters.
    # This includes all characters except for newline, space and tab
    # However, &nbsp; does create a space which is why we can't use \S.
    isStartOfElement: ->
      throw "#isStartOfElement() needs to be overridden with a browser specific implementation"

    # Returns true if the current range is at the end of the given element.
    # We are at end of the element if there are no width-generating
    # characters. This includes all characters except for newline, space and
    # tab. However, &nbsp; does create a space which is why we can't use \S.
    isEndOfElement: ->
      throw "#isEndOfElement() needs to be overridden with a browser specific implementation"

    # Get the coordinates of the range.
    # Returns { top, bottom, left, right }
    #
    # NOTE:
    # Each browser has a different implementation to return the coordinates.
    #
    # The original solution attempted to solve this in a general way. It
    # inserted a span where the range was and grabbed the coordinates of the
    # span. Then it destroyed the span. However, this posed two problems:
    # 1. When the range was not collapsed, the span would replace whatever was
    # selected.
    # 2. It used Editor.Range.insertNode() which calls range.focus(). this made
    # IE jump up and down due to the focus.
    # TODO: Problem #2 is invalid. range.focus() doesn't exist and #insertNode()
    # doesn't call #focus().
    #
    # The second solution attempted to account for an uncollapsed range in a
    # general way by
    # 1. Save the range
    # 2. Collapse to the beginning and find the coordinates using the span
    # 3. Reselect the saved range
    # 4. Collapse to the end and find the coordinates using the span
    # 5. Reselect the saved range
    # Unfortunately, there were two problems:
    # 1. IE still exhibited the jumping due to range.focus().
    # TODO: Problem #1 is invalid. range.focus() doesn't exist.
    # 2. When reselecting the saved range, the W3C browsers lost which
    # direction the selection was made. It always set the selection to be
    # selecting forwards. Hence, if you attempted to continue selecting
    # backwards, it would lose your previous selection and start over again.
    # Note that IE retained memory of which way the selection was going.
    #
    # The final solution implements a solution for each browser and leverages
    # the tools available to each browser and takes into consideration the
    # quirks each browser exhibits.
    getCoordinates: ->
      throw "#getCoordinates() needs to be overridden with a browser specific implementation"

    # Finds the first parent element from the range that matches the argument.
    # If the range is not collapsed, it starts the search at the common
    # ancestor element.
    # The match can be a function or a CSS pattern like "a[name=mainlink]". If
    # you want to escape the lookup early, throw Range.EDITOR_ESCAPE_ERROR in
    # the function.
    # Returns the matched parent element or null.
    getParentElement: (match) ->
      switch Helpers.typeOf(match)
        when "function" then matchFn = match
        when "string" then matchFn = (el) -> $(el).filter(match).length > 0
        when "null" then matchFn = -> true
        when "undefined" then matchFn = -> true
        else throw "invalid type for match"
      el = @getImmediateParentElement()
      return null unless el
      try
        while true
          if el == @el or el == @doc.body
            # If we are at the top el, then we are done. No match.
            el = null
            break
          else if matchFn(el)
            # If match is true, then return it.
            break
          else
            # Else keep searching parents.
            el = el.parentNode
      catch e
        if e == Range.EDITOR_ESCAPE_ERROR
          el = null
        else
          throw e
      el

    # Finds the start and end parent elements from the range that matches the
    # argument.
    getParentElements: (match) ->
      if @isImageSelected()
        # If an image is selected, the start and end parents are the same.
        startParentElement = endParentElement = @getParentElement(match)
      else
        startRange = @clone()
        startRange.collapse(true)
        startParentElement = startRange.getParentElement(match)
        endRange = @clone()
        endRange.collapse(false)
        endParentElement = endRange.getParentElement(match)
      return [startParentElement, endParentElement]

    # Get the text selected by the range.
    getText: ->
      throw "#getText() needs to be overridden with a browser specific implementation"

    #
    # MANIPULATE RANGE FUNCTIONS
    #

    # If start is true, collapses to start of range.
    # Otherwise collapses to end of range.
    collapse: (start) ->
      @range.collapse(start)
      this

    # Select the given range or its own range if none given.
    select: (range) ->
      throw "#select() needs to be overridden with a browser specific implementation"

    # Unselects the range.
    unselect: ->
      throw "#unselect() needs to be overridden with a browser specific implementation"

    # Select the contents of the element.
    selectElementContents: (el) ->
      throw "#selectElementContents() needs to be overridden with a browser specific implementation"

    # Move selection to the inside of the end of the element.
    selectEndOfElement: (el) ->
      throw "#selectEndOfElement() needs to be overridden with a browser specific implementation"

    # Saves the range, executes the given fn, then reselects the range.
    # The function is given the start and end spans as arguments.
    #
    # NOTE: This inserts spans at the beginning and end of the range. These
    # cannot be removed. If they are, the reselection will fail. Be careful
    # what the given function does.
    keepRange: (fn) ->
      throw "#keepRange() needs to be overridden with a browser specific implementation"

    # Moves one of the range's boundary to the start/end of the el.
    # Arguments:
    # * boundaries - "starttostart", "starttoend", "endtostart", "endtoend"
    # * el - element to move to
    #
    # The first boundary refers to the range's boundary. The second boundary
    # refers to the el's boundary. Capitalization is normalized.
    moveBoundary: (boundaries, el) ->
      throw "#moveBoundary() needs to be overridden with a browser specific implementation"

    #
    # MODIFY RANGE CONTENT FUNCTIONS
    #

    # Insert the given arg.
    # arg:
    #   - HTML string: inserts the HTML string as is
    #   - element: inserts the element
    #
    # NOTE: The browser may normalize the content.
    insert: (arg) ->
      # If an image is selected, all browsers insert beside the image instead of
      # replacing the image. Hence, we manually delete the image first and then
      # insert.
      @delete() if @isImageSelected()
      switch Helpers.typeOf(arg)
        when "string" then @insertHTML(arg)
        when "element" then @insertNode(arg)
        else throw "Don't know how to insert this type of arg"

    # Surround range with element.
    surroundContents: (el) ->
      throw "#surroundContents() needs to be overridden with a browser specific implementation"

    # Delete the contents of the range.
    delete: ->
      throw "#delete() needs to be overridden with a browser specific implementation"

  Helpers.extend(Range, Module.static)
  Helpers.include(Range, Module.instance)
  Helpers.include(Range, Coordinates)

  return Range

# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/browser", "core/helpers/helpers.keyboard"], ($, Browser, Keyboard) ->
  Helpers =
    #
    # CONSTANTS
    #

    # Used when dealing with HTML like in innerHTML.
    zeroWidthNoBreakSpace: "&#65279;"
    # Used when dealing with text like in regex or textnodes.
    zeroWidthNoBreakSpaceUnicode: "\ufeff"

    buttons:
      left: 1
      middle: 2
      right: 3

    # This is a hash of the different node types.
    #
    # NOTE: There are more node types, but these are the ones we use.
    #
    # NOTE: W3C browsers have a Node object that contains the values. For
    # example, Node.ELEMENT_NODE will return 1. Unfortunately, IE does not have
    # such an object.
    nodeType:
      ELEMENT: 1
      TEXT: 3

    #
    # DOM
    #

    # Check if an object is an element.
    isElement: (object) ->
      object and object.nodeName and object.nodeType == @nodeType.ELEMENT

    # Check if an object is a textnode.
    isTextnode: (object) ->
      object and object.nodeName and object.nodeType == @nodeType.TEXT

    # Check if an object is a block.
    isBlock: (object, inDOM = true) ->
      return false unless @isElement(object)
      $object = $(object)
      # Add this special case because IE7 displays <hr> as inline.
      # Treat images as block elements.
      return true if $object.tagName() == "hr" or $object.tagName() == "img"
      unless inDOM
        $container = $("<div/>").hide().appendTo("body")
        $object.appendTo($container)
      isBlock = $object.css("display") != "inline"
      unless inDOM
        $object.detach()
        $container.remove()
      return isBlock

    # Returns true if the el is empty. False otherwise.
    isEmpty: (el) ->
      $el = $(el)
        # Check for any HTML tags that take up space. Currently only images
        # take up space. If there are, we are not at the end.
      return false if $el.find("img").length > 0
      # Check for empty text.
      !!$el.text().match(@emptyRegExp)

    # Returns an array of the nodes between and including startNode and endNode.
    # This assumes the startNode and endNode have the same parent.
    nodesFrom: (startNode, endNode) ->
      nodes = []
      return nodes unless startNode and endNode
      node = startNode
      loop
        nodes.push(node)
        break if node == endNode
        node = node.nextSibling
      return nodes

    # Returns the previous/next sibling by walking up the DOM until a sibling
    # is found. Returns null if no sibling is found.
    # Arguments:
    # which - previous/next
    # node - node to start looking
    # stopEl - stop at this el (default: body)
    # isSibling - function to check whether the found sibling is considered a
    # sibling
    getSibling: (which, node, stopEl, isSibling) ->
      stopEl or= $(@getDocument(node)).find("body")[0]
      isSibling or= (node) -> node
      sibling = null
      current = node
      # Walk up the DOM looking for the previous/next sibling until the stopEl
      # is hit or a sibling is found.
      while current != stopEl and !sibling
        sibling = current["#{which}Sibling"]
        # Look for a sibling that is considered a sibling.
        while sibling and !isSibling(sibling)
          sibling = sibling["#{which}Sibling"]
        current = current.parentNode
      sibling

    # Get the sibling cell. Returns null if none is found.
    # Arguments:
    # cell - current cell
    # next - true to find next cell, false to find previous cell
    getSiblingCell: (cell, next) ->
      $cell = $(cell)
      direction = if next then "next" else "prev"
      # Find the immediate sibling.
      $siblingCell = $cell[direction]("td, th")
      # If there is no immediate sibling, go to the sibling row.
      if $siblingCell.length == 0
        $parentRow = $cell.parent("tr")
        $siblingRow = $parentRow[direction]("tr")
        # If there is a sibling row, grab the sibling cell from the sibling row.
        if $siblingRow.length > 0
          position = if direction == "next" then "first" else "last"
          $siblingCell = $siblingRow.find("td, th")[position]()
      return $siblingCell[0] or null

    # Runs up the parent chain and returns the node at the top.
    getTopNode: (node, stopNode) ->
      topNode = node
      parent = topNode.parentNode
      while parent != stopNode
        topNode = parent
        parent = topNode.parentNode
      return topNode

    # Returns the element's document.
    getDocument: (el) ->
      el.ownerDocument

    # Returns the element's window.
    getWindow: (el) ->
      doc = @getDocument(el)
      doc.defaultView or doc.parentWindow

    # Returns the parent iframe that contains the el.
    # Returns null if the el is not inside an iframe.
    getParentIFrame: (el) ->
      doc = @getDocument(el)
      $("iframe").filter(-> this.contentWindow.document == doc)[0] or null

    # Replace the given node with its children.
    # If there are no children, the node is simply removed.
    replaceWithChildren: (node) ->
      parent = node.parentNode
      parent.insertBefore(node.childNodes[0], node) while node.childNodes[0]
      parent.removeChild(node)

    # Inserts the given styles into a <style> tag in the <head>.
    insertStyles: (styles) ->
      return if $.trim(styles).length == 0
      style = $('<style type="text/css" />')[0]
      # Don't check for style.styleSheet. IE9 has this property but it doesn't
      # work properly. Therefore, we have to revert to checking directly for
      # IE7/8.
      if Browser.isIE7 or Browser.isIE8
        style.styleSheet.cssText = styles
      else
        style.innerHTML = styles
      $(style).appendTo("head")

    # Transforms the given coords so that they are relative to the outer
    # window.
    #
    # coords can be of 2 types:
    # 1. { x: <int>, y: <int> }
    # 2. { top: <int>, bottom: <int>, left: <int>, right: <int> }
    transformCoordinatesRelativeToOuter: (coords, iframe) ->
      iframeScroll = $(iframe.win).getScroll()
      iframeCoords = $(iframe).getCoordinates()
      # Since the coords are relative to the iframe window, we need to
      # translate them so they are relative to the viewport of the iframe and
      # then add on the coordinates of the iframe.
      if typeof coords.top == "undefined"
        outerCoords =
          x: Math.round(coords.x - iframeScroll.x + iframeCoords.left)
          y: Math.round(coords.y - iframeScroll.y + iframeCoords.top)
      else
        outerCoords =
          top: Math.round(coords.top - iframeScroll.y + iframeCoords.top)
          bottom: Math.round(coords.bottom - iframeScroll.y + iframeCoords.top)
          left: Math.round(coords.left - iframeScroll.x + iframeCoords.left)
          right: Math.round(coords.right - iframeScroll.x + iframeCoords.left)
      outerCoords

    getWindowBoundary: (win = window) ->
      windowSize = $(win).getSize()
      windowScroll = $(win).getScroll()
      return {
        top: windowScroll.y
        bottom: windowScroll.y + windowSize.y
        left: windowScroll.x
        right: windowScroll.x + windowSize.x
      }

    #
    # Object
    #

    # Mimics MoooTools typeOf.
    typeOf: (object) ->
      type = $.type(object)
      return type unless type == "object"
      return "element" if @isElement(object)
      return "textnode" if @isTextnode(object)
      return "window" if $.isWindow(object)
      return type

    # Extend module into class.
    extend: (klass, module) ->
      $.extend(klass, module)

    # Include module into class.
    include: (klass, module) ->
      for key, value of module
        klass.prototype[key] = value

    # Delegate the fns from object to del.
    # del:
    #   A string that corresponds to the key to access the delegate from the
    #   object.
    #   If the delegate is a function, the string can end in "()".
    # fns:
    #   Strings to represent the functions to delegate.
    delegate: (object, del, fns...) ->
      # Check to see if the delegate is a function.
      isDelFn = del.slice(-2) == "()"
      del = del.substring(0, del.length-2) if isDelFn

      # A separate function is needed because the for loop does not create a
      # new scope.
      delFn = (object, fn) ->
        object[fn] = ->
          delObject = object[del]
          delObject = delObject.apply(object) if isDelFn
          delObject[fn](arguments...)
      for fn in fns
        throw "Delegate: #{fn} is already defined on #{object}" if typeof object[fn] != "undefined"
        throw "Delegate: #{del} does not exist on #{object}" if typeof object[del] == "undefined"
        delFn(object, fn)

    # Deep clones the given object.
    deepClone: (object) ->
      switch $.type(object)
        when "object"
          clone = {}
          clone[key] = @deepClone(val) for own key, val of object
        when "array"
          clone = []
          clone.push(@deepClone(o)) for o in object
        else
          clone = object
      clone

    #
    # Function
    #

    # Taken from MooTools.
    pass: (fn, args, bind) ->
      -> fn.apply(bind, $.makeArray(args))

    #
    # String
    #

    # Taken from MooTools.
    capitalize: (string) ->
      string.replace(/\b[a-z]/g, (match) -> match.toUpperCase())

    # Uncapitalize the string.
    uncapitalize: (string) ->
      string.replace(/\b[A-Z]/g, (match) -> match.toLowerCase())

    # Changes a string from camel case to snake case.
    # e.g. "someMadeUpName" -> "some_made_up_name"
    camelToSnake: (string) ->
      Helpers.uncapitalize(string).replace(/[A-Z]/g, (match) -> "_" + match.toLowerCase())

    # Changes ctrl+shift+a to Ctrl+Shift+A.
    displayShortcut: (shortcut) ->
      $.map(shortcut.split("+"), (s) -> Helpers.capitalize(s)).join("+")

    # Normalizes the URL.
    normalizeURL: (url) ->
      normalizedUrl = url
      if /@/.test(url)
        # Normalize email.
        normalizedUrl = "mailto:#{url}"
      else
        matches = url.match(/^([a-z]+:|)(\/\/.*)$/)
        if matches
          # Normalize URL.
          protocol = if matches[1].length > 0 then matches[1] else "http:"
          normalizedUrl = protocol + matches[2]
        else
          # Normalize path.
          normalizedUrl = "http://#{url}" unless url.charAt(0) == "/"
      normalizedUrl

    #
    # Arrays
    #

    # Returns only unique values in the array. Only works for primitive data
    # types.
    uniqueArray: (array) ->
      unique = {}
      uArray = []
      for a in array
        continue if unique[a]
        uArray.push(a)
        unique[a] = true
      uArray

  $.extend(Helpers, Keyboard)

  Helpers.emptyRegExp = new RegExp("^[\n\t#{Helpers.zeroWidthNoBreakSpaceUnicode} ]*$")

  return Helpers

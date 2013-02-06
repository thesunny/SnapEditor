define ["jquery.custom", "core/browser", "core/helpers/helpers.keyboard"], ($, Browser, Keyboard) ->
  Helpers = {
    #
    # CONSTANTS
    #
     
    zeroWidthNoBreakSpace: "&#65279;"
    zeroWidthNoBreakSpaceUnicode: "\ufeff"

    buttons: {
      left: 1
      middle: 2
      right: 3
    }

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
      unless inDOM
        $container = $("<div/>").hide().appendTo("body")
        $object.appendTo($container)
      isBlock = $object.css("display") != "inline"
      # Add this special case because IE7 displays <hr> as inline.
      isBlock = true if $object.tagName() == "hr"
      unless inDOM
        $object.detach()
        $container.remove()
      return isBlock

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
    # window. The target is a node in the same window the coords are currently
    # relative to.
    #
    # coords can be of 2 types:
    # 1. { x: <int>, y: <int> }
    # 2. { top: <int>, bottom: <int>, left: <int>, right: <int> }
    transformCoordinatesRelativeToOuter: (coords, target) ->
      # Nothing to transform since the target is part of the outer window.
      return coords if @getDocument(target) == document
      iframeScroll = $(@getWindow(target)).getScroll()
      iframeCoords = $(Helpers.getParentIFrame(target)).getCoordinates()
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
  }

  $.extend(Helpers, Keyboard)

  Helpers.emptyRegExp = new RegExp("^[\n\t#{Helpers.zeroWidthNoBreakSpaceUnicode} ]*$")

  return Helpers

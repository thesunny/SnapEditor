define ["jquery.custom", "core/browser", "core/helpers/helpers.keyboard"], ($, Browser, Keyboard) ->
  Helpers = {
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

    # Check if an object is an element.
    isElement: (object) ->
      object.nodeName and object.nodeType == @nodeType.ELEMENT

    # Check if an object is a textnode.
    isTextnode: (object) ->
      object.nodeName and object.nodeType == @nodeType.TEXT

    # Check if an object is a block.
    isBlock: (object, inDOM = true) ->
      return false unless @isElement(object)
      $object = $(object)
      unless inDOM
        $container = $("<div/>").hide().appendTo("body")
        $object.appendTo($container)
      isBlock = $object.css("display") != "inline"
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

    # Returns the element's document.
    getDocument: (el) ->
      el.ownerDocument

    # Returns the element's window.
    getWindow: (el) ->
      doc = @getDocument(el)
      doc.defaultView or doc.parentWindow

    # Replace the given node with its children.
    replaceWithChildren: (node) ->
      parent = node.parentNode
      parent.insertBefore(node.childNodes[0], node) while node.childNodes[0]
      parent.removeChild(node)
      doc = @getDocument(el)
      doc.defaultView or doc.parentWindow

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

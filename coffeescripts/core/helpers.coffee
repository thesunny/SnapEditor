define ["jquery.custom", "core/helpers/helpers.keyboard"], ($, Keyboard) ->
  Helpers = {
    zeroWidthNoBreakSpace: "&#65279;"
    zeroWidthNoBreakSpaceUnicode: "\ufeff"

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

  return Helpers

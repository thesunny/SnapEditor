define ["cs!jquery.custom"], ($) ->
  return {
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
      object.nodeName && object.nodeType == @nodeType.ELEMENT

    # Check if an object is a textnode.
    isTextnode: (object) ->
      object.nodeName && object.nodeType == @nodeType.TEXT

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

    # Keyboard key mappings taken from MooTools.
    keys:
      enter: 13,
      up: 38,
      down: 40,
      left: 37,
      right: 39,
      esc: 27,
      space: 32,
      backspace: 8,
      tab: 9,
      delete: 46

    # Returns the string representation of the key pressed. Taken from MooTools.
    keyOf: (event) ->
      # Check for function key.
      if event.type == 'keydown'
        fKey = event.which - 111
        key = 'f' + fKey if 0 < fKey < 13
      unless key
        # Check for special key.
        for own k, v of @keys
          key = k if v == event.which
        # If still no match, a character key was pressed.
        key = String.fromCharCode(event.which).toLowerCase() unless key
      key

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

define ["cs!jquery.custom"], ($) ->
  return {
    # Puts.
    p: ->
      # We can't just use
      #   if console
      # or
      #   if !!console
      # because IE craps all over the place when console is undefined
      # complaining that it is undefined.
      #
      # We also can't just stop at console.log because CoffeeScript compiles it
      # down to
      #   console.log.apply(...)
      # Apparently, in IE, if you open the developer tool bar (F12), it adds
      # console.log. Unfortunately, for some crazy reason, console.log.apply is
      # undefined. Hence, even though IE now has the ability to console.log, we
      # can't use it.
      if typeof console != "undefined" and typeof console.log != "undefined"
        if typeof console.log.apply == "undefined"
          console.log(a) for a in arguments
        else
          console.log(arguments...)
      else
        alert(a) for a in arguments

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

# This is the API to the editor.
#
# Properties:
# el: the DOM element that represents the editor
#
# Event Handling Functions:
# on(event, handlerFn): when event is triggred, handlerFn will be called
# off(event, handlerFn): stop listening to the event
# trigger(event, args): event to trigger and an array of args to pass through
#
# Property Functions:
# getContents(): gets the contents of the editor
#
# Editor Functions:
# activate(): activates the editor
# clean(): clean the HTML
#
# Range Functions:
# range([el]): returns the current selection if el is not given, else returns the range that represents the el
# select(el): selects the el
define ["jquery.custom", "core/api/api.exec_command", "core/helpers", "core/events", "core/range"], ($, ExecCommand, Helpers, Events, Range) ->
  class API
    constructor: (@editor) ->
      @el = @editor.$el[0]
      @doc = Helpers.getDocument(@el)
      @win = Helpers.getWindow(@el)
      @config = @editor.config
      @assets = @editor.assets
      @lang = @editor.lang
      @execCommand = new ExecCommand(this)
      @whitelist = @editor.whitelist
      Helpers.delegate(this, "editor",
        "getContents", "setContents", "activate", "tryDeactivate", "deactivate", "save"
      )
      Helpers.delegate(this, "assets", "file", "image", "stylesheet", "template")
      Helpers.delegate(this, "getRange()",
        "isValid", "isCollapsed", "isImageSelected", "isStartOfElement", "isEndOfElement",
        "getParentElement", "getParentElements", "getText",
        "collapse", "unselect", "keepRange", "moveBoundary",
        "insert", "surroundContents", "delete"
      )
      Helpers.delegate(this, "getBlankRange()", "selectNodeContents", "selectEndOfElement")
      Helpers.delegate(this, "execCommand",
        "formatBlock", "formatInline", "indent", "outdent",
        "insertUnorderedList", "insertOrderedList", "insertHorizontalRule", "insertLink"
      )
      Helpers.delegate(this, "whitelist", "isAllowed", "getReplacement", "getNext")

      # The default is to deactivate immediately. However, to accommodate
      # plugins such as the Save plugin, this can be disabled and handled in a
      # customized way. Use #disableImmediateDeactivate.
      @on("snapeditor.tryDeactivate", @deactivate)

    #
    # DOM SHORTCUTS
    #

    # Shortcut to the doc's createElement().
    createElement: (name) ->
      @doc.createElement(name)

    # Shortcut to the doc's createTextNode().
    createTextNode: (text) ->
      @doc.createTextNode(text)

    # Shortcut to find elements in the doc. Always returns an array.
    find: (selector) ->
      $(@doc).find(selector).toArray()

    #
    # EVENTS
    #

    disableImmediateDeactivate: ->
      @off("snapeditor.tryDeactivate", @deactivate)

    #
    # RANGE
    #

    # Gets the current selection if el is not given.
    # Otherwise returns the range that represents the el.
    # If a selection does not exist, use #getBlankRange().
    getRange: (el) ->
      new Range(@el, el or @win)

    # Get a blank range. This is here in case a selection does not exist.
    # If a selection exists, use #getRange().
    getBlankRange: ->
      new Range(@el)

    # Select the given arg. If no arg is given, selects the current selection.
    # NOTE: This is not directly delegated to the Range object because it is
    # slightly different. This takes a given argument and selects it.
    # Arguments:
    # * arg - Either a SnapEditor Range or DOM element.
    select: (arg) ->
      if arg and arg.collapse
        range = arg
      else
        range = @getRange(arg)
      range.select()

    # Add the coordinates relative to the outer window.
    getCoordinates: (range) ->
      range or= @getRange()
      coords = range.getCoordinates()
      coords.outer = $.extend({}, Helpers.transformCoordinatesRelativeToOuter(coords, @el))
      coords

    #
    # MISCELLANEOUS
    #

    # Gets the default block from the whitelist.
    getDefaultBlock: ->
      @whitelist.getDefaults()["*"].getElement(@doc)

    # Calls the cleaner with the given arguments.
    clean: ->
      @trigger("clean", arguments)

  Helpers.include(API, Events)

  return API

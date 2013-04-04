define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  class API
    constructor: (@editor) ->
      @el = @editor.el
      @doc = @editor.doc
      @win = @editor.win
      @config = @editor.config
      @plugins = @editor.plugins
      @commands = @editor.commands
      Helpers.delegate(this, "editor",
        # EVENTS
        "on", "off", "trigger",
        "activate", "tryDeactivate", "disableImmediateDeactivate", "deactivate",
        "update", "clean", "save",
        # CONTENTS
        "getContents", "setContents",
        # DOM
        "createElement", "createTextNode", "find",
        "insertStyles",
        # KEYBOARD
        "addKeyboardShortcut", "removeKeyboardShortcut",
        # ASSETS
        "imageAsset", "flashAsset",
        # WHITELIST
        "isAllowed", "getReplacement",
        "getDefaultBlock", "getNext",
        # RANGE
        "getRange", "getBlankRange",
        "isValid", "isCollapsed", "isImageSelected", "isStartOfElement", "isEndOfElement",
        "getParentElement", "getParentElements", "getText", "getCoordinates",
        "collapse", "unselect", "keepRange", "moveBoundary",
        "insert", "surroundContents", "delete",
        "select", "selectNodeContents", "selectEndOfElement",
        "formatBlock", "formatInline", "align", "indent", "outdent",
        "insertUnorderedList", "insertOrderedList", "insertHorizontalRule", "insertLink"
      )

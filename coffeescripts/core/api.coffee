define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  class API
    constructor: (@editor) ->
      @el = @editor.el
      @doc = @editor.doc
      @win = @editor.win
      @config = @editor.config
      Helpers.delegate(this, "editor",
        # EVENTS
        "on", "off", "trigger",
        "activate", "tryDeactivate", "deactivate",
        "update", "clean",
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
        # WIDGETS
        "createWidget",
        # ACTIONS
        "execAction",
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

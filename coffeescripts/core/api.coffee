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
        # ACTIONS
        "activate", "tryDeactivate", "deactivate",
        "update", "clean",
        "execAction",
        # RANGE
        "getRange",
        "isValid", "isCollapsed", "isImageSelected", "isStartOfElement", "isEndOfElement",
        "getParentElement", "getParentElements", "getText", "getCoordinates",
        "collapse", "unselect", "keepRange", "moveBoundary",
        "insert", "surroundContents", "delete",
        "select", "selectElementContents", "selectEndOfElement",
        "styleBlock", "formatInline", "align", "indent", "outdent",
        "insertUnorderedList", "insertOrderedList", "insertHorizontalRule", "insertLink"
      )

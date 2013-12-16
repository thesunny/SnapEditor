# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
#
# The Editor's API is used as the public interface to the editor. We put it into
# a separate object to make it more explicit what is supposed to be public.
define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  class API
    constructor: (@editor) ->
      # This @el is the editable element (i.e. the element inside the iframe
      # that the user is editing). This is not the element that has been
      # marked for editing. @doc and @win are related to the editable element
      # as well.
      @el = @editor.el
      @doc = @editor.doc
      @win = @editor.win
      @config = @editor.config
      Helpers.delegate(this, "editor",
        # EVENTS
        "on", "off", "trigger",
        # ENABLE
        "enable", "disable", "isEnabled",
        # CONTENTS
        "getContents", "setContents",
        # DOM
        "createElement", "createTextNode", "find",
        "insertStyles",
        # KEYBOARD
        "addKeyboardShortcut", "removeKeyboardShortcut",
        # ASSETS
        "imageAsset", "flashAsset",
        # BUTTONS
        "getStyleButtonsByTag",
        # WHITELIST
        "addWhitelistRule", "addWhitelistGeneralRule",
        "isAllowed", "getReplacement",
        "getDefaultBlock", "getNext",
        # WIDGETS
        "insertWidget",
        # DIALOGS
        "openDialog", "closeDialog",
        # ACTIONS
        "activate", "tryDeactivate", "deactivate",
        "update", "clean",
        "execAction",
        # RANGE
        "getRange", "lockRange", "unlockRange",
        "isValid", "isCollapsed", "isImageSelected", "isStartOfElement", "isEndOfElement",
        "getParentElement", "getParentElements", "getText", "getCoordinates",
        "collapse", "unselect", "keepRange", "moveBoundary",
        "insert", "surroundContents", "delete",
        "select", "selectElementContents", "selectEndOfElement",
        "styleBlock", "formatInline", "align", "indent", "outdent",
        "insertUnorderedList", "insertOrderedList", "insertHorizontalRule", "insertLink"
      )

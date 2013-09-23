# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/browser", "core/helpers", "plugins/editable/editable.others", "plugins/editable/editable.ie"], ($, Browser, Helpers, Others, IE) ->
  editable =
    # Turn on editing in the div. This includes preserving the caret position
    # as editing is turned on in all browsers.
    #
    # If an image inside the editor was clicked to start editing, then
    # clickedImage should be set to true. False otherwise.
    start: ->
      throw "Editable.start() needs to be overridden with a browser specific implementation"

    # turns editing off in the div. Includes removing the focus from the div.
    deactivate: (api) ->
      api.el.contentEditable = false
      api.el.blur()
      @deactivateBrowser(api)

    deactivateBrowser: (api) ->
      # Overridden by browser specific implementation.

  SnapEditor.behaviours.editable =
    onActivateClick: (e) -> editable.start(e.api)
    onDeactivate: (e) -> editable.deactivate(e.api)

  Helpers.extend(editable, if Browser.isIE then IE else Others)

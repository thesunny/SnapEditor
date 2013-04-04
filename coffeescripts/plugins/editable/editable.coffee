define ["jquery.custom", "core/browser", "core/helpers", "plugins/editable/editable.others", "plugins/editable/editable.ie"], ($, Browser, Helpers, Others, IE) ->
  window.SnapEditor.internalPlugins.editable =
    events:
      activateClick: (e) -> e.api.plugins.editable.start(e.api)
      deactivate: (e) -> e.api.plugins.editable.deactivate(e.api)

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

  Helpers.extend(window.SnapEditor.internalPlugins.editable, if Browser.isIE then IE else Others)

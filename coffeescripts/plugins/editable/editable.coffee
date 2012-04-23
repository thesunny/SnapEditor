define ["jquery.custom", "core/browser", "core/helpers", "plugins/editable/editable.others", "plugins/editable/editable.ie"], ($, Browser, Helpers, Others, IE) ->
  class Editable
    register: (@api) ->
      @api.on("click.activate", => @start.apply(this))

    # Turn on editing in the div. This includes preserving the caret position
    # as editing is turned on in all browsers.
    #
    # If an image inside the editor was clicked to start editing, then
    # clickedImage should be set to true. False otherwise.
    start: ->
      throw "Editable.start() needs to be overridden with a browser specific implementation"

    # turns editing off in the div. Includes removing the focus from the div.
    deactivate: () ->
      @el.contentEditable = false
      @el.blur()
      @deactivateBrowser()

    deactivateBrowser: () ->
      # Overridden by browser specific implementation.

  Module = if Browser.isIE then IE else Others
  Helpers.include(Editable, Module)

  return Editable

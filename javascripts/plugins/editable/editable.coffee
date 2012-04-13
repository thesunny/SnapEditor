define ["cs!jquery.custom", "cs!core/browser", "cs!core/helpers", "cs!plugins/editable/editable.others", "cs!plugins/editable/editable.ie"], ($, Browser, Helpers, Others, IE) ->
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
    finish: () ->
      @el.contentEditable = false
      @el.blur()
      @_finish()

    _finish: () ->
      # Overridden

  Module = if Browser.isIE then IE else Others
  Helpers.include(Editable, Module)

  return Editable

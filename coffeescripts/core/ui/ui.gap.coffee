define ["jquery.custom"], ($) ->
  class Gap
    constructor: (template) ->
      @$template = $(template)

    # Generates the HTML for the toolbar.
    htmlForToolbar: ->
      @$template.html()

    # Generates the HTML for the contextmenu.
    htmlForContextMenu: ->
      throw "A gap cannot be used for a contextmenu"

    # Generates the CSS for the toolbar.
    cssForToolbar: ->
      ""

    # Generates the CSS for the contextmenu.
    cssForContextMenu: ->
      throw "A gap cannot be used for a contextmenu"

  return Gap

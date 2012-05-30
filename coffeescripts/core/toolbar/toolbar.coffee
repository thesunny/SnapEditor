# Toolbar API:
# * getUI():
#     Returns an object with keys corresponding to the string which will be
#     used in the toolbar config. The values are UI component objects or an
#     array of UI component objects.
#
#     The UI component objects must have the following functions:
#     * htmlForToolbar()
#     * cssForToolbar()
#
#     Each UI component object should have an action that will be triggered
#     from the editor API.
#
#     It is expected that the returned object specifies a default using the
#     "toolbar:default" key.
#
# * getActions():
#     Returns an object with keys corresponding to the actions which will be triggered from the editor API. The values should be callbacks to handle the event.
#     e.g.
#       {
#         "bold": function () {},
#         "italic": function () {}
#       }
#
# The templates argument is an element that contains the following id:
# * snapeditor_toolbar_template
#
# NOTE: The following is taken from Toolbar.Builder for reference.
# The components argument is an array of components.
# * "|" specifies a division between groups of components.
# * "-" specifies a gap between components.
# * Strings are mapped to the availableComponents.
# e.g.
#   [
#     "Bold", "Italic", "-", "Underline", "|",
#     "H1", "H2", "H3", "|",
#     "Left, "Center", "Right", "|",
#     "Image", "Link", "Table", "|"
#   ]
define ["jquery.custom", "core/helpers", "core/data_action_handler", "core/toolbar/toolbar.builder"], ($, Helpers, DataActionHandler, Builder) ->
  class Toolbar
    constructor: (@api, templates, @availableComponents, @components) ->
      @$templates = $(templates)
      @$toolbar = null
      @setupTemplates()

    setupTemplates: ->
      @$template = @$templates.find("#snapeditor_toolbar_template")
      if @$template.length == 0
        throw "Missing template. Make sure there is an element with id snapeditor_toolbar_template."

    # Sets up the toolbar.
    setup: ->
      [@$toolbar, @css] = new Builder(@$template, @availableComponents, @components).build()
      # Ensure the toolbar does not deactivate the editor.
      @$toolbar.addClass("snapeditor_ignore_deactivate")
      @dataActionHandler = new DataActionHandler(@$toolbar, @api)
      Helpers.insertStyles(@css)

  return Toolbar

# Toolbar API:
# * getToolbar():
#     Returns an object with keys corresponding to the string which will be
#     used in the toolbar config. The values are functions which can return
#     an array of component objects or an HTML string.
#     1. Component objects should have the following keys:
#         * class (optional)
#         * title
#         * event
#        This tells the builder to automatically generate a component from the
#        template with the particular class and title. When the component is
#        clicked, "<event>.toolbar" will be triggered from the editor API.
#     2. HTML string will be rendered as is. It must have a "data-event"
#        attribute in order to trigger any events.
# * getDefaultToolbar():
#     Returns a string which is one of the keys in the call to getToolbar().
# * getToolbarActions():
#     Returns an object with keys corresponding to the events to listen to. The
#     values should be callbacks to handle the event.
#     NOTE: ".toolbar" does not need to appeneded to the event.
#     e.g.
#       {
#         "bold": function () {},       // correct
#         "bold.toolbar": function() {} // incorrect
#       }
#
# The plugins argument is an array of objects that implement the Toolbar API.
#
# NOTE: The following is taken from Toolbar.Builder for reference.
#
# The templates argument is a jQuery object that contains the following ids:
# * snapeditor_toolbar_template
# * snapeditor_toolbar_button_template
# * snapeditor_toolbar_gap_template
#
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
define ["jquery.custom", "core/data_action_handler", "core/toolbar/toolbar.builder"], ($, DataActionHandler, Builder) ->
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
      @$toolbar = new Builder(@$template, @availableComponents, @components).build()
      @dataActionHandler = new DataActionHandler(@$toolbar, @api)

  return Toolbar

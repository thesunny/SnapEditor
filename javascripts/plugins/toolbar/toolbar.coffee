# Toolbar API:
# * getToolbar():
#     Returns an object with keys corresponding to the string which will be
#     used in the toolbar config. The values are functions which can return
#     an array of button objects or an HTML string.
#     1. Button objects should have the following keys:
#         * class (optional)
#         * title
#         * event
#        This tells the builder to automatically generate a button from the
#        template with the particular class and title. When the button is
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
# * snapeditor_toolbar_button_gap_template
#
# The buttons argument is an array of buttons.
# * "|" specifies a division between groups of buttons.
# * "-" specifies a gap between buttons.
# * Strings are mapped to the availableButtons.
# e.g.
#   [
#     "Bold", "Italic", "-", "Underline", "|",
#     "H1", "H2", "H3", "|",
#     "Left, "Center", "Right", "|",
#     "Image", "Link", "Table", "|"
#   ]
define ["cs!jquery.custom", "cs!config/config.default", "cs!core/data_event_handler", "cs!plugins/toolbar/toolbar.builder", "cs!plugins/toolbar/toolbar.displayer.floating"], ($, Default, DataEventHandler, Builder, FloatingDisplayer) ->
  class Toolbar
    namespace: "toolbar",

    constructor: (@plugins, templates, @buttons = []) ->
      @customButtons = @buttons.length > 0
      @$templates = $(templates)
      @$toolbar = null

    register: (@api) ->
      @api.on("activate.editor", @show)
      @api.on("deactivate.editor", @hide)

    # Sets up the toolbar. Is only executed once.
    setup: ->
      @setupPlugins()
      @$toolbar = new Builder(@$templates, @availableButtons, @buttons).build()
      @dataEventHandler = new DataEventHandler(@$toolbar, @api, @namespace)
      @displayer = new FloatingDisplayer(@$toolbar, @api.el, @api)

    setupPlugins: ->
      @availableButtons = {}
      @addPlugin(plugin) for plugin in @plugins

    addPlugin: (plugin) ->
      # Ensure that there is a default specified.
      throw "The toolbar plugin is missing a default" unless plugin.getDefaultToolbar
      # Add the buttons.
      $.extend(@availableButtons, plugin.getToolbar())
      # Add any toolbar actions.
      @addActions(plugin) if plugin.getToolbarActions
      # If there was no config for the toolbar, then we append the default
      # buttons to the end of the existing toolbar.
      unless @customButtons
        @buttons.push("|") unless @buttons.length == 0
        @buttons.push(plugin.getDefaultToolbar())

    addActions: (plugin) ->
      # NOTE: We need the @addAction function because CoffeeScript uses the
      # same action variable throughout the entire loop. This causes binding
      # issues where the event handler is bound to the action variable.
      # Therefore, when the action variable changes, so does the event handler.
      # Basically, all the actions will point to the last action added. To
      # break this binding, we call a new function.
      @addAction(plugin, event, action) for event, action of plugin.getToolbarActions()

    addAction: (plugin, event, action) ->
      # Ensure that the action is bound to the plugin.
      @api.on("#{event}.#{@namespace}", -> action.apply(plugin, arguments))

    # Shows the toolbar.
    show: =>
      @setup() unless @$toolbar
      @displayer.show()

    # Hides the toolbar.
    hide: =>
      @displayer.hide() if @$toolbar

  return Toolbar

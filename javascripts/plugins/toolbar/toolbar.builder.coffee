# This builds the toolbar from the given button groups.
# 
# Arguments:
# * templates_url - where to grab the templates from
# * availableButtons - a map of available buttons
# * buttons - the buttons to display
#
# The templates argument is a jQuery object that contains the following ids:
# * snapeditor_toolbar_template
# * snapeditor_toolbar_button_template
# * snapeditor_toolbar_button_gap_template
#
# The format of the availableButtons is an object with keys corresponding to
# the strings which will be used in the buttonGroups and with values which are
# functions that either return an HTML string or an array of button objects.
# The HTML string should contain an element with the attribute "data-event" in
# order to trigger the event.
# The button objects should have the following keys:
# * class (optional)
# * title
# * event
# e.g.
#   {
#     Bold: function () { return [{"class": "bold-button", title: "Bold", event: "bold"}]; }
#     "MyPlugin.Embed": function() { return '<button data-event="myplugin.embed">button</button>'; }
#   }
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
define ["cs!jquery.custom", "cs!core/helpers", "cs!core/data_event_handler"], ($, Helpers) ->
  class ToolbarBuilder
    constructor: (templates, @availableButtons, @buttons) ->
      @$templates = $(templates)

    # Builds the toolbar with the given button groups.
    build: ->
      @setupTemplates()
      $toolbar = $(@toolbarTemplate.mustache(buttonGroups: @getButtons()))
      $toolbar.find("[data-event]").each(->$(this).attr("unselectable", "on"))
      return $toolbar

    setupTemplates: ->
      @toolbarTemplate = @$templates.find("#snapeditor_toolbar_template")
      @buttonTemplate = @$templates.find("#snapeditor_toolbar_button_template")
      @gapTemplate = @$templates.find("#snapeditor_toolbar_button_gap_template")
      @checkTemplates()
      @availableButtons["-"] = => @gapTemplate.html()

    checkTemplates: ->
      if @toolbarTemplate.length == 0
        throw "Missing template. Make sure there is an element with id snapeditor_toolbar_template."
      if @buttonTemplate.length == 0
        throw "Missing template. Make sure there is an element with id snapeditor_toolbar_button_template."
      if @gapTemplate.length == 0
        throw "Missing template. Make sure there is an element with id snapeditor_toolbar_button_gap_template."

    getButtons: ->
      htmlButtonGroups = []
      htmlButtons = []
      for button in @buttons
        if button == "|"
          # If there is a new group, store the old one and create a new one.
          htmlButtonGroups.push(buttons: htmlButtons)
          htmlButtons = []
        else
          # If it is a button, continue adding it to the current group.
          htmlButtons.push(html: @getButtonHtml(button))
      # Store the last group if there are buttons in it.
      htmlButtonGroups.push(buttons: htmlButtons) unless htmlButtons.length == 0
      return htmlButtonGroups

    getButtonHtml: (button) ->
      renderer = @availableButtons[button]
      throw "The button(s) for #{button} is not available. Please check that the plugin has been included." unless renderer
      output = if Helpers.typeOf(renderer) == "function" then renderer() else renderer
      switch Helpers.typeOf(output)
        when "string" then return output
        when "array" then return @buildButtons(output)
        else throw "Unknown toolbar format. Expecting an HTML string or an array of button objects. Please check the API. #{output}"

    buildButtons: (buttons) ->
      html = ""
      for button in buttons
        throw "The button is missing a title attribute: #{button}" unless button.title
        throw "The button is missing an event attribute: #{button}" unless button.event
        html += @buttonTemplate.mustache(button)
      return html

  return ToolbarBuilder

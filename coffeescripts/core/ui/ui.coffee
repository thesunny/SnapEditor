# UI components have the following functions:
# * htmlForToolbar - generates the HTML string for a toolbar
# * htmlForContextMenu - generates the HTML string for a contextmenu
# * cssForToolbar - generates the CSS string for a toolbar
# * cssForContextMenu - generates the CSS string for a contextmenu
define ["jquery.custom", "core/ui/ui.button", "core/ui/ui.gap", "core/ui/ui.dialog"], ($, Button, Gap, Dialog) ->
  class UI
    # Templates should be an element that contains the following ids:
    # * snapeditor_toolbar_button_template
    # * snapeditor_toolbar_select_template
    # * snapeditor_toolbar_gap_template
    # * snapeditor_contextmenu_button_template
    # * snapeditor_dialog_template
    constructor: (templates) ->
      @$templates = $(templates)
      @setupTemplates()

    # Grabs all the templates.
    setupTemplates: ->
      @$tbButtonTemplate = @$templates.find("#snapeditor_toolbar_button_template")
      @$tbSelectTemplate = @$templates.find("#snapeditor_toolbar_select_template")
      @$tbGapTemplate = @$templates.find("#snapeditor_toolbar_gap_template")
      @$cmButtonTemplate = @$templates.find("#snapeditor_contextmenu_button_template")
      @$dialogTemplate = @$templates.find("#snapeditor_dialog_template")
      @checkTemplates()

    # Checks that all the templates are defined.
    checkTemplates: ->
      if @$tbButtonTemplate.length == 0
        throw "Missing template. Make sure there is an element with id snapeditor_toolbar_button_template."
      #if @$tbSelectTemplate.length == 0
        #throw "Missing template. Make sure there is an element with id snapeditor_toolbar_select_template."
      if @$tbGapTemplate.length == 0
        throw "Missing template. Make sure there is an element with id snapeditor_toolbar_gap_template."
      if @$cmButtonTemplate.length == 0
        throw "Missing template. Make sure there is an element with id snapeditor_contextmenu_button_template."
      if @$dialogTemplate.length == 0
        throw "Missing template. Make sure there is an element with id snapeditor_dialog_template."

    # Generates a button object.
    # NOTE: Copied from ui.button.coffee for reference.
    # Options:
    # action: the action to trigger
    # description: description for the button
    # shortcut: keyboard shortcut for the button (optional)
    # icon: the icon of the button as an object (optional)
    #   {
    #     url: <url>,     // mandatory
    #     width: x,       // mandatory, either integer or string
    #     height: y,      // mandatory, either integer or string
    #     offset: [x, y]  // optional
    #   }
    button: (options) ->
      templates =
        toolbar: @$tbButtonTemplate
        contextmenu: @$cmButtonTemplate
      new Button(templates, options)

    # Generates a gap object.
    gap: ->
      new Gap(@$tbGapTemplate)

    # el will be placed inside the dialog.
    dialog: (html, classname = "") ->
      new Dialog(@$dialogTemplate, html, classname)

  return UI

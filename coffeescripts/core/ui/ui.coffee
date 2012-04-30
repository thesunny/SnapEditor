define ["jquery.custom", "core/ui/ui.button", "core/ui/ui.gap"], ($, Button, Gap) ->
  class UI
    constructor: (templates) ->
      @$templates = $(templates)
      @setupTemplates()

    # Grabs all the templates.
    setupTemplates: ->
      @$tbButtonTemplate = @$templates.find("#snapeditor_toolbar_button_template")
      @$tbSelectTemplate = @$templates.find("#snapeditor_toolbar_select_template")
      @$tbGapTemplate = @$templates.find("#snapeditor_toolbar_gap_template")
      @$cmButtonTemplate = @$templates.find("#snapeditor_contextmenu_button_template")
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

    # Generates a button object.
    button: (options) ->
      templates =
        toolbar: @$tbButtonTemplate
        contextmenu: @$cmButtonTemplate
      new Button(templates, options)

    # Generates a gap object.
    gap: ->
      new Gap(@$tbGapTemplate)

  return UI

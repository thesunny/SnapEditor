define ["jquery.custom"], ($) ->
  class ToolbarUI
    constructor: (templates) ->
      @$templates = $(templates)
      @setupTemplates()

    setupTemplates: ->
      @$buttonTemplate = @$templates.find("#snapeditor_toolbar_button_template")
      @$selectTemplate = @$templates.find("#snapeditor_toolbar_select_template")
      @checkTemplates()

    checkTemplates: ->
      if @$buttonTemplate.length == 0
        throw "Missing template. Make sure there is an element with id snapeditor_toolbar_button_template."
      #if @$selectTemplate.length == 0
        #throw "Missing template. Make sure there is an element with id snapeditor_toolbar_select_template."

    button: (options = {}) ->
      throw "The toolbar's ui.button() expects an 'action' option" unless options.action
      if options.attrs
        attrs = ""
        attrs += "#{attr}=\"#{value}\" " for attr, value of options.attrs
        options.attrs = attrs
      => @$buttonTemplate.mustache(options)

  return ToolbarUI

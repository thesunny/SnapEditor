define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  class Button
    # Arguments:
    # templates: { toolbar: <template>, contextmenu: <template> }
    #
    # Options:
    # action: the action to trigger
    # title: the title of the button
    # icon: the icon of the button either as a url or { url: <url>, offset: [x, y] }
    constructor: (templates, @options) ->
      @$tbTemplate = $(templates.toolbar)
      @$cmTemplate = $(templates.contextmenu)
      @checkOptions()
      @options.icon = @normalizeIcon(@options.icon)

    # Ensure all the options are correct.
    checkOptions: ->
      if typeof @options == "undefined"
        throw "Missing button UI options"

      if typeof @options.action == "undefined"
        throw "Missing action for button UI"

      if typeof @options.title == "undefined"
        throw "Missing title for #{@options.action} button UI"

      switch Helpers.typeOf(@options.icon)
        when "undefined" then throw "Missing icon for #{@options.action} button UI"
        when "object"
          if typeof @options.icon.url == "undefined"
            throw "Icon must have a url for #{@options.action} button UI"
          if typeof @options.icon.offset == "undefined"
            throw "Icon must have an offset for #{@options.action} button UI"

    # Normalize the icon so that it is an object.
    # { url: <url>, offset: [x, y] }
    normalizeIcon: (icon) ->
      icon = url: icon, offset: [0, 0] if typeof icon == "string"
      return icon

    # Generates a class for the particular type and action.
    # action is stripped of all non-alphanumeric characters.
    generateClass: (type, action) ->
      "snapeditor_#{type}_#{action.replace(/[^a-zA-Z0-9]+/g, "")}"


    # Generates the HTML for the toolbar.
    htmlForToolbar: ->
      @$tbTemplate.mustache(
        action: @options.action
        title: @options.title
        class: @generateClass("toolbar", @options.action)
      )

    # Generates the HTML for the contextmenu.
    htmlForContextMenu: ->
      @$cmTemplate.mustache(
        action: @options.action
        title: @options.title
        class: @generateClass("contextmenu", @options.action)
      )

    # Generates the CSS for the toolbar.
    cssForToolbar: ->
      klass = @generateClass("toolbar", @options.action)
      "
        #{klass} {
          background-image: url(#{@options.icon.url});
          background-repeat: no-repeat;
          background-position: #{@options.icon.offset[0]} #{@options.icon.offset[1]};
        }
        "

    # Generates the CSS for the contextmenu.
    cssForContextMenu: ->
      klass = @generateClass("contextmenu", @options.action)
      "
        #{klass} div {
          float: left;
        }
        #{klass} icon {
          background-image: url(#{@options.icon.url});
          background-repeat: no-repeat;
          background-position: #{@options.icon.offset[0]} #{@options.icon.offset[1]};
        }
      "

  return Button

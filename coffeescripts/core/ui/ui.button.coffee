define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  class Button
    # Arguments:
    # templates: { toolbar: <template>, contextmenu: <template> }
    #
    # Options:
    # action: the action to trigger
    # description: description for the button
    # shortcut: keyboard shortcut for the button
    # icon: the icon of the button as an object (optional)
    #   {
    #     url: <url>,     // mandatory
    #     width: x,       // mandatory, either integer or string
    #     height: y,      // mandatory, either integer or string
    #     offset: [x, y]  // optional
    #   }
    constructor: (templates, @options) ->
      @$tbTemplate = $(templates.toolbar)
      @$cmTemplate = $(templates.contextmenu)
      @checkOptions()
      @normalizeIcon()

    # Ensure all the options are correct.
    checkOptions: ->
      if typeof @options == "undefined"
        throw "Missing button UI options"

      if typeof @options.action == "undefined"
        throw "Missing action for button UI"

      if typeof @options.description == "undefined"
        throw "Missing description for #{@options.action} button UI"

      iconType = Helpers.typeOf(@options.icon)
      if iconType != "undefined"
        if iconType != "object"
          throw "Icon must be an object for #{@options.action} button UI"
        if typeof @options.icon.url == "undefined"
          throw "Icon must have a url for #{@options.action} button UI"
        if typeof @options.icon.width == "undefined"
          throw "Icon must have a width for #{@options.action} button UI"
        if typeof @options.icon.height == "undefined"
          throw "Icon must have a height for #{@options.action} button UI"

    normalizeIcon: ->
      if @options.icon
        @options.icon.offset or= [0, 0]
        @options.icon.width = "#{@options.icon.width}px" if Helpers.typeOf(@options.icon.width) == "number"
        @options.icon.height = "#{@options.icon.height}px" if Helpers.typeOf(@options.icon.height) == "number"

    # Generates a class for the particular type and action.
    # action is stripped of all non-alphanumeric characters.
    generateClass: (type, action) ->
      @class or= "snapeditor_#{type}_#{action.replace(/[^a-zA-Z0-9]+/g, "")}".toLowerCase()

    getTitle: ->
      return @title if @title
      @title = @options.description
      @title += " (#{@options.shortcut})" if @options.shortcut

    # Generates the HTML for the toolbar.
    htmlForToolbar: ->
      @$tbTemplate.mustache(
        action: @options.action
        title: @getTitle()
        class: @generateClass("toolbar", @options.action)
      )

    # Generates the HTML for the contextmenu.
    htmlForContextMenu: ->
      @$cmTemplate.mustache(
        action: @options.action
        description: @options.description
        shortcut: @options.shortcut
        class: @generateClass("contextmenu", @options.action)
      )

    # Generates the CSS for the toolbar.
    cssForToolbar: ->
      return "" unless @options.icon
      classname = @generateClass("toolbar", @options.action)
      "
        .#{classname} input {
          background-image: url(#{@options.icon.url});
          background-repeat: no-repeat;
          background-position: #{@options.icon.offset[0]}px #{@options.icon.offset[1]}px;
          background-color: transparent;
          border: 1px solid transparent;
          width: #{@options.icon.width};
          height: #{@options.icon.height};
        }
        .#{classname} input:hover {
          background-color: #D0E0F0;
          border: 1px solid #98A8B8;
        }
      "

    # Generates the CSS for the contextmenu.
    cssForContextMenu: ->
      classname = @generateClass("contextmenu", @options.action)
      css = "
        .#{classname} {
          width: 100%;
          height: 30px;
        }
        .#{classname} button {
          background-color: white;
          border: none;
          padding: 0px 0px 0px 5px;
          width: 100%;
          height: 30px;
        }
        .#{classname} button:hover {
          background-color: #f9ffd0;
        }
        .#{classname} table {
          border-collapse: collapse;
          border-spacing: 0px;
          border: none;
          width: 100%;
        }
        .#{classname} td {
          border: none;
          padding: 0px;
          height: 30px;
        }
        .#{classname} .snapeditor_contextmenu_description {
          text-align: left;
          padding-left: 5px;
          width: 60%;
        }
        .#{classname} .snapeditor_contextmenu_shortcut {
          text-align: right;
          font-size: 90%;
          color: #505050;
          padding-right: 5px;
          width: 40%;
        }
      "
      if @options.icon
        css += "
          .#{classname} .snapeditor_contextmenu_icon {
            width: #{@options.icon.width}
          }
          .#{classname} .snapeditor_contextmenu_icon div {
            background-image: url(#{@options.icon.url});
            background-repeat: no-repeat;
            background-position: #{@options.icon.offset[0]}px #{@options.icon.offset[1]}px;
            width: #{@options.icon.width};
            height: #{@options.icon.height};
          }
        "
      else
        css += "
          .#{classname} .snapeditor_contextmenu_icon {
            width: 0px;
          }
        "

  return Button

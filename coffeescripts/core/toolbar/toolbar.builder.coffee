# This builds the toolbar from the given component groups.
# 
# Arguments:
# * template - element holding the toolbar template
# * availableComponents - a map of available components
# * components - the components to display
#
# The format of the availableComponents is an array of objects that respond to
# htmlForToolbar() and cssForToolbar().
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
define ["jquery.custom", "core/browser", "core/helpers"], ($, Browser, Helpers) ->
  class ToolbarBuilder
    constructor: (@api, template, @availableComponents, @components) ->
      @$template = $(template)

    # Builds the toolbar with the given component groups.
    # Returns [toolbar, css]
    build: ->
      [components, css] = @getComponents()
      $toolbar = $(@$template.mustache(componentGroups: components))
      if Browser.isIE
        $toolbar.attr("unselectable", "on")
        $toolbar.find("*").each(-> $(this).attr("unselectable", "on"))
      else if Browser.isGecko
        $toolbar.css("-moz-user-select", "none")
      else if Browser.isWebkit
        # Webkit has a -webkit-user-select style, but it doesn't behave like
        # Firefox. Instead, we listen to the mousedown and if it didn't come
        # from a button, we save the range. When the click occurs, we reselect
        # the range.
        $toolbar.on(mousedown: @handleMouseDown, click: @handleClick)
      return [$toolbar, css]

    handleMouseDown: (e) =>
      @savedRange = @api.getRange() unless $(e.target).attr("data-action")

    handleClick: (e) =>
      @savedRange.select() unless $(e.target).attr("data-action")

    # Returns an array of component groups.
    # e.g.
    #   [
    #     [{components: {html: "HTML string"}}, ...],
    #     ...
    #   ]
    getComponents: ->
      groups = []
      html = ""
      css = ""
      for component in @components
        if component == "|"
          # If there is a new group, store the old one and create a new one.
          groups.push(html: html)
          html = ""
        else
          # If it is a component, continue adding it to the current group.
          [componentHTML, componentCSS] = @getComponentHtmlAndCss(component)
          html += componentHTML
          css += componentCSS
      # Store the last group if there are components in it.
      groups.push(html: html) unless html.length == 0
      groups[groups.length-1].last = true if groups.length > 0
      return [groups, css]

    # Return the HTML and CSS strings that correspond to the component.
    getComponentHtmlAndCss: (key) ->
      html = ""
      css = ""
      # Normalize the key to lowercase.
      components = @availableComponents[key.toLowerCase()]
      throw "The component(s) for #{key} is not available. Please check that the plugin has been included." unless components
      for component in components
        switch Helpers.typeOf(component)
          when "string" then [componentHTML, componentCSS] = @getComponentHtmlAndCss(component)
          when "object" then [componentHTML, componentCSS] = [component.htmlForToolbar(), component.cssForToolbar()]
          else throw "Unrecognized component format for '#{key}'. Expecting a string or UI component object"
        html += componentHTML
        css += componentCSS
      return [html, css]

  return ToolbarBuilder

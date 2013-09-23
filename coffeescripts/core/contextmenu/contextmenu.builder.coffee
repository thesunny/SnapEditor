# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
define ["jquery.custom", "core/helpers"], ($, Helpers) ->
  class ContextMenuBuilder
    # buttons - { "<context selector>": [<button object>, ...]
    constructor: (template, @buttons) ->
      @$template = $(template)
      @contextHTML = {}

    build: (contexts) ->
      $menu = $(@$template.mustache(componentGroups: @getComponents(contexts)))
      $menu.find("[data-action]").each(->$(this).attr("unselectable", "on"))
      return $menu

    getComponents: (contexts) ->
      groups = []
      groups.push(html: @generateHTMLForContext(context)) for context in contexts
      groups[groups.length-1].last = true
      return groups

    generateHTMLForContext: (context) ->
      return @contextHTML[context] if @contextHTML[context]
      html = ""
      css = ""
      buttons = @buttons[context]
      buttons or= [] if context == "default"
      throw "Missing contextmenu buttons for context '#{context}'" unless buttons
      for button in buttons
        html += button.htmlForContextMenu()
        css += button.cssForContextMenu()
      Helpers.insertStyles(css)
      @contextHTML[context] = html

  return ContextMenuBuilder

define ["jquery.custom", "core/helpers", "core/browser"], ($, Helpers, Browser) ->
  return {
    # Options:
    # * items
    # * editor
    # * templates
    #   * container
    #   * item
    #   * divider
    # * menu
    #   * class
    #   * options
    # * itemBuilder
    build: (items, options) ->
      $container = $(options.templates.container)
      $content = $container.find("ul")
      $content.menus = []
      @addItem($content, item, options) for item in items
      $container.menus = $content.menus
      # IE7 and IE8 destroy the range when it is collapsed and the toolbar is
      # clicked. In order to prevent this, we set unselectable to on for every
      # element in the toolbar.
      # IE9/10 does not work properly without unselectable set to on.
      if Browser.isIE
        $container.find("*").each(-> $(this).attr("unselectable", "on"))
        $container.attr("unselectable", "on")
      $container

    # Options:
    # * editor
    # * templates
    #   * item
    #   * divider
    # * menu
    #   * class
    #   * options
    # * itemBuilder
    addItem: ($content, item, options) ->
      if item == "|"
        $(options.templates.divider).appendTo($content)
      else
        # Make sure the button has been defined.
        button = SnapEditor.buttons[item]
        throw "Button does not exist: #{item}. Buttons are case sensitive." unless button
        throw "Missing text for button #{item}." unless button.text
        throw "Missing action for button #{item}." unless button.action or button.items
        # Add the button.
        $item = $(options.templates.item).appendTo($content)
        options.itemBuilder($item.find("a"), item, button)
        actionHandler = (e) ->
          # If this is a final action that doesn't trigger another menu, let
          # others know so they can close their menus.
          e.api.trigger("snapeditor.toolbar_final_action")
          e.api.execAction(button.action, e)
        # If there are items, we need to create a dropdown. We ignore the
        # action given by the button. Instead, the action should trigger the
        # dropdown.
        if button.items
          menu = new options.menu.class(options.editor, $item, button.items, options.menu.options)
          menu.$menu.addClass("snapeditor_toolbar_menu_#{Helpers.camelToSnake(item)}")
          actionHandler = (e) ->
            # If the menu is not a flyout (i.e. a dropdown) and is already
            # shown, then hide it.
            # Else, show the menu.
            if !menu.options.flyOut and menu.isShown()
              menu.hide(e)
            else
              # Hide all the other menus before showing ths one.
              m.hide(e) for m in $content.menus
              menu.show()
          $content.menus.push(menu)
        options.editor.on(item, (e) ->
          # In Webkit, after the toolbar is clicked, the focus hops to the parent
          # window. We need to refocus it back into the iframe. Focusing breaks IE
          # and kills the range so the focus is only for Webkit. It does not affect
          # Firefox.
          e.api.win.focus() if Browser.isWebkit
          actionHandler(e)
        )
  }

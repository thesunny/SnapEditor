# Copyright (c) 2012-2013 8098182 Canada Inc. All rights reserved.
# For licensing, see LICENSE.
# = Toolbar API
#
# == Buttons
#
# Buttons can be defined in the global SnapEditor.buttons object.
#
# Mandatory keys:
# * text - the title for the button and the text for the menu item if html is
#   not specified
# * action - a function or string to handle the action (optional if items is
#   specified)
#
# Optional keys:
# * html - html for menu items
# * shortcut - keyboard shortcut with '+' as the delimiter
# * items - array of buttons for a submenu
#
# == Buttons/Menu Items
#
# === Classes
#
# The button's class is built from the snake case of the corresponding button.
#   snapeditor_toolbar_icon_<snake case of the button>
#
# The menu's class is built from the snake case of the corresponding button.
#   snapeditor_toolbar_menu_<snake case of the button>
#
# The menu items do not have specific classes because the button developer
# has full control over the HTML inside the menu item.
#
# == Shortcut
#
# When specified, the action function will be triggered when the shortcut is
# pressed.
#
# The shortcut is included in the title in parentheses and modified for
# displaying.
#   shortcut: ctrl+b
#   title: Bold (Ctrl+B)
#
# The shortcut is included in the menu item and modified for displaying.
#   shortcut: ctrl+b
#   menu item: Bold     Ctrl+B
#
# == Action
#
# When buttons and menu items that don't have submenus are clicked, they
# trigger the corresponding action.
#
# The action function has one argument: an action event.
#
# The action event contains access to the SnapEditor API.
#   e.api
#
# == Submenus
#
# To add submenus, specify the items array and populate it with buttons.
#   items: ["bold", "italic"]
#
# Menu items will automatically have a right triangle to indicate the
# availability of a submenu.
#
# There are no limits to submenus, but we don't recommend more than 2 levels
# deep.
#
# Example
#
# SnapEditor.buttons = {
#   style: {
#     text: "Style",
#     items: ["styleInline", "styleBlock"]
#   },
#   styleInline: {
#     text: "Style Inline",
#     html: '<span class="important">Style Inline</span>',
#     items: ["bold", "italic"]
#   },
#   bold: {
#     text: "Bold",
#     shortcut: "ctrl+b",
#     action: function (e) { e.api.bold(); }
#   },
#   italic: {
#     text: "Italic",
#     shortcut: "ctrl+i",
#     action: function (e) { e.api.italic(); }
#   },
#   styleBlock: {
#     text: "Style Block",
#     html: '<span class="important">Style Block</span>',
#     items: ["h1", "h2"]
#   },
#   h1: {
#     text: "H1",
#     shortcut: "ctrl+alt+1",
#     action: function (e) { e.api.h1(); }
#   },
#   h2: {
#     text: "H2",
#     shortcut: "ctrl+alt+2",
#     action: function (e) { e.api.h2(); }
#   }
# };

define ["jquery.custom", "core/helpers", "core/browser", "core/data_action_handler", "core/toolbar/toolbar.button"], ($, Helpers, Browser, DataActionHandler, Button) ->
  class Menu
    # Options:
    # * editor
    constructor: (@button, @options) ->
      @buttons = []
      @submenus = []

    getMenuTemplate: ->
      throw "#getMenuTemplate() must be overridden"

    getItemTemplate: ->
      throw "#getItemTemplate() must be overridden"

    getDividerTemplate: ->
      throw "#getDividerTemplate() must be overridden"

    getCSSKey: ->
      throw "#getCSSKey() must be overridden"

    getCSS: ->
      throw "#getCSS() must be overridden"

    getDataActionHandler: ->
      new DataActionHandler(@$el, @options.editor.api)

    getSubmenuClass: ->
      throw "#getSubmenuClass() must be overridden"

    getActionHandler: (button, submenu = null) ->
      self = this
      (e) ->
        if submenu
          self.showSubmenu(submenu, e)
        else
          # If this is a final action that doesn't trigger another menu, let
          # others know so they can close their menus.
          e.api.trigger("snapeditor.toolbar_final_action")
          e.api.execAction(button.action, e)

    showSubmenu: (submenu, e) ->
      # Hide all the other menus before showing this one.
      sm.hide(e) for sm in @submenus
      submenu.show()

    buildItem: ($container, button) ->
      throw "#buildItem() must be overridden"

    setup: ->
      unless @$el
        @$el = $(@getMenuTemplate()).hide().appendTo("body")
        @$content = @$el.find("ul")
        @addItems()
        @options.editor.insertStyles(@getCSSKey(), @getCSS())
        @dataActionHandler = @getDataActionHandler()

    isShown: ->
      @shown

    show: =>
      unless @shown
        @setup()
        @dataActionHandler.activate()
        @renderButtons()
        @$el.show()
        @shown = true
      # Prevent the if statement from above from returning false and stopping
      # propagation.
      return true

    hide: =>
      if @shown
        @setup()
        @hideSubmenus()
        @$el.hide()
        @shown = false
      # Prevent the if statement from above from returning false and stopping
      # propagation.
      return true

    hideSubmenus: ->
      menu.hide() for menu in @submenus

    addItems: ->
      @addItem(item) for item in @button.getItems(api: @options.editor.api)
      # IE7 and IE8 destroy the range when it is collapsed and the toolbar is
      # clicked. In order to prevent this, we set unselectable to on for every
      # element in the toolbar.
      # IE9/10 does not work properly without unselectable set to on.
      if Browser.isIE
        @$el.find("*").each(-> $(this).attr("unselectable", "on"))
        @$el.attr("unselectable", "on")

    addItem: (item) ->
      if item == "|"
        $(@getDividerTemplate()).appendTo(@$content)
      else
        # Make sure the button has been defined.
        buttonOptions = SnapEditor.buttons[item]
        throw "Button does not exist: #{item}. Buttons are case sensitive." unless buttonOptions
        throw "Missing text for button #{item}." unless buttonOptions.text
        throw "Missing action for button #{item}." unless buttonOptions.action or buttonOptions.items
        button = new Button(item, buttonOptions)
        # Add the button.
        button.setEl($(@getItemTemplate()).appendTo(@$content))
        @buildItem(button.getEl().find("a"), button)
        # If there are items, we need to create a dropdown. We ignore the
        # action given by the button. Instead, the action should trigger the
        # dropdown.
        if button.getItems(api: @options.editor.api).length > 0
          klass = @getSubmenuClass()
          submenu = new klass(button, editor: @options.editor, relEl: button.getEl())
          @submenus.push(submenu)
        actionHandler = @getActionHandler(button, submenu)
        @options.editor.on(button.cleanName, (e) ->
          # In Webkit, after the toolbar is clicked, the focus hops to the parent
          # window. We need to refocus it back into the iframe. Focusing breaks IE
          # and kills the range so the focus is only for Webkit. It does not affect
          # Firefox.
          e.api.win.focus() if Browser.isWebkit
          actionHandler(e)
        )
        @buttons.push(button)

    renderButtons: ->
      button.render(@options.editor.api) for button in @buttons
